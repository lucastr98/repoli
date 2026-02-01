use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::Json,
    routing::{get, post},
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
    id: i64,
    title: String,
    content: String,
    created_at: String,
}

#[derive(Serialize, Deserialize)]
struct CreateRecipe {
    title: String,
    content: String,
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
        .route("/health", get(health_check))
        .route("/recipes", get(list_recipes).post(create_recipe))
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
    "Hello, Recipe API! 🍳"
}

async fn health_check() -> StatusCode {
    StatusCode::OK
}

async fn list_recipes(State(state): State<AppState>) -> Result<Json<Vec<Recipe>>, StatusCode> {
    let recipes = sqlx::query_as::<_, Recipe>("SELECT id, title, content, created_at FROM recipes")
        .fetch_all(&state.db)
        .await
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(recipes))
}

async fn create_recipe(
    State(state): State<AppState>,
    Json(input): Json<CreateRecipe>,
) -> Result<Json<Recipe>, StatusCode> {
    let recipe = sqlx::query_as::<_, Recipe>(
        "INSERT INTO recipes (title, content) VALUES (?, ?) RETURNING id, title, content, created_at"
    )
    .bind(&input.title)
    .bind(&input.content)
    .fetch_one(&state.db)
    .await
    .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    
    Ok(Json(recipe))
}

async fn get_recipe(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<Recipe>, StatusCode> {
    let recipe = sqlx::query_as::<_, Recipe>(
        "SELECT id, title, content, created_at FROM recipes WHERE id = ?"
    )
    .bind(id)
    .fetch_one(&state.db)
    .await
    .map_err(|_| StatusCode::NOT_FOUND)?;
    
    Ok(Json(recipe))
}
