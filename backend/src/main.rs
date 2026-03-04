use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Json,
    routing::get,
    Router,
};
use tower_http::cors::{CorsLayer, Any};
use serde::{Deserialize, Serialize};
use sqlx::{sqlite::SqlitePool, FromRow};

#[derive(Clone)]
struct AppState {
    db: SqlitePool,
}

#[derive(Serialize, Deserialize, FromRow)]
struct Recipe {
    title: String,
    instructions: String,
    #[sqlx(json)]
    ingredients: Vec<Ingredient>,
}

#[derive(Serialize, Deserialize)]
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
        .route("/recipes", get(list_recipes))
        .route("/units", get(list_units))
        .route("/ingredients", get(list_ingredients))
        // .route("/recipes", get(list_recipes).post(create_recipe))
        .route("/recipes/{id}", get(get_recipe))
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

async fn list_recipes(State(state): State<AppState>) -> Result<Json<Vec<Recipe>>, StatusCode> {
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

// async fn create_recipe(
//     State(state): State<AppState>,
//     Json(input): Json<CreateRecipe>,
// ) -> Result<Json<Recipe>, StatusCode> {
//     let recipe = sqlx::query_as::<_, Recipe>(
//         "INSERT INTO recipes (title, instructions) VALUES (?, ?) RETURNING id, title, instructions, created_at"
//     )
//     .bind(&input.title)
//     .bind(&input.instructions)
//     .fetch_one(&state.db)
//     .await
//     .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
//     Ok(Json(recipe))
// }

async fn list_units(State(state): State<AppState>) -> Result<Json<Vec<String>>, StatusCode> {
    let query = "SELECT name FROM units";
    let units = sqlx::query_scalar::<_, String>(query)
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(units))
}

async fn list_ingredients(State(state): State<AppState>) -> Result<Json<Vec<String>>, StatusCode> {
    let query = "SELECT name FROM ingredients";
    let ingredients = sqlx::query_scalar::<_, String>(query)
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(ingredients))
}
