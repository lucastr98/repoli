use axum::{
    Router, extract::{Path, State}, http::StatusCode, response::Json, routing::{get, post}
};
use tower_http::cors::{CorsLayer, Any};
use serde::{Deserialize, Serialize};
use sqlx::{sqlite::SqlitePool, FromRow};

#[derive(Clone)]
struct AppState {
    db: SqlitePool,
}

#[derive(Serialize, Deserialize, FromRow, Debug)]
struct Recipe {
    title: String,
    instructions: String,
    #[sqlx(json)]
    ingredients: Vec<Ingredient>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Ingredient {
    name: String,
    quantity: Option<f64>,
    unit: String,
}

#[tokio::main]
async fn main() {
    // Initialize database
    let database_url = std::env::var("DATABASE_URL")
        .unwrap_or_else(|_| "sqlite://recipes.db?mode=rwc".to_string());
    
    let db = SqlitePool::connect(&database_url)
        .await
        .expect("Failed to connect to database");
    
    // Run migrations
    sqlx::migrate!("./migrations")
        .run(&db)
        .await
        .expect("Failed to run migrations");
    
    let state = AppState { db };
    
    // Build router
    let app = Router::new()
        .route("/", get(hello))
        .route("/recipes", get(get_recipes))
        .route("/units", get(get_units))
        .route("/ingredients", get(get_ingredients))
        .route("/recipes/{id}", get(get_recipe))
        .route("/recipe", post(create_recipe))
        .layer(
            CorsLayer::new()
                .allow_origin(Any)
                .allow_methods(Any)
                .allow_headers(Any)
        )
        .with_state(state);
    
    // Start server
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .expect("Failed to bind to port");
    
    println!("🚀 Server running on http://localhost:3000");
    
    axum::serve(listener, app)
        .await
        .expect("Failed to start server");
}

async fn hello() -> &'static str {
    "Hello, Repoli API! 🍳"
}

async fn get_recipes(State(state): State<AppState>) -> Result<Json<Vec<Recipe>>, StatusCode> {
    let query = r#"
        SELECT 
            r.title, 
            r.instructions, 
            json_group_array(
                json_object(
                    'name', i.name,
                    'quantity', ri.quantity,
                    'unit', u.name
                )
            ) AS ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        JOIN ingredients i ON ri.ingredient_id = i.id
        JOIN units u ON ri.unit_id = u.id
        GROUP BY r.id
    "#;
    let recipes = sqlx::query_as::<_, Recipe>(query)
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(recipes))
}

async fn get_recipe(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Recipe>, StatusCode> {
    let query = r#"
        SELECT 
            r.title, 
            r.instructions, 
            json_group_array(
                json_object(
                    'name', i.name,
                    'quantity', ri.quantity,
                    'unit', u.name
                )
            ) AS ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        JOIN ingredients i ON ri.ingredient_id = i.id
        JOIN units u ON ri.unit_id = u.id
        WHERE r.id = ?
        GROUP BY r.id
    "#;
    let recipe = sqlx::query_as::<_, Recipe>(query)
        .bind(id)
        .fetch_one(&state.db)
    .await
    .map_err(|_| StatusCode::NOT_FOUND)?;
    
    Ok(Json(recipe))
}

async fn create_recipe(
    State(state): State<AppState>,
    Json(input): Json<Recipe>,
) -> Result<StatusCode, (StatusCode, String)> {
    // Start a transaction
    let mut tx = state.db.begin().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let recipe_id = sqlx::query!(
        "INSERT INTO recipes (title, instructions) VALUES (?, ?) RETURNING id",
        input.title,
        input.instructions
    )
    .fetch_one(&mut *tx)
    .await
    .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
    .id;

    for ingredient in input.ingredients {
        sqlx::query!(
            r#"
            INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id)
            VALUES (
                ?, 
                (SELECT id FROM ingredients WHERE name = ?), 
                ?, 
                (SELECT id FROM units WHERE name = ?)
            )
            "#,
            recipe_id,
            ingredient.name,
            ingredient.quantity,
            ingredient.unit
        )
        .execute(&mut *tx)
        .await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Failed to link ingredient {}: {}", ingredient.name, e)))?;
    }

    // Commit the transaction
    tx.commit().await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    Ok(StatusCode::CREATED)
}

async fn get_units(State(state): State<AppState>) -> Result<Json<Vec<String>>, StatusCode> {
    let query = "SELECT name FROM units";
    let units = sqlx::query_scalar::<_, String>(query)
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(units))
}

async fn get_ingredients(State(state): State<AppState>) -> Result<Json<Vec<String>>, StatusCode> {
    let query = "SELECT name FROM ingredients";
    let ingredients = sqlx::query_scalar::<_, String>(query)
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(ingredients))
}
