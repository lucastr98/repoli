# Repoli Backend

REST API server for the Repoli app.

## Tech Stack
- **Rust** - Systems programming language
- **Axum** - Web framework
- **SQLx** - Async SQL toolkit
- **SQLite** - Database
- **Tokio** - Async runtime

## Project Structure
```
backend/
├── src/
│   └── main.rs          # API routes and handlers
├── migrations/          # Database migrations
│   └── 20260128000001_create_recipes_table.sql
├── Cargo.toml          # Dependencies
└── recipes.db          # SQLite database (auto-created)
```

## Running

```bash
cargo run
```

Server starts on `http://localhost:3000`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Hello message |
| GET | `/health` | Health check |
| GET | `/recipes` | List all recipes |
| POST | `/recipes` | Create a recipe |
| GET | `/recipes/{id}` | Get recipe by ID |

### Request/Response Examples

**Create Recipe:**
```bash
curl -X POST http://localhost:3000/recipes \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Chocolate Cake",
    "content": "Mix ingredients and bake at 350°F for 30 minutes."
  }'
```

**Response:**
```json
{
  "id": 1,
  "title": "Chocolate Cake",
  "content": "Mix ingredients and bake at 350°F for 30 minutes.",
  "created_at": "2026-01-30T12:34:56"
}
```

## Database

SQLite database with automatic migrations. The database file (`recipes.db`) is created automatically on first run.


## Configuration

Set the `DATABASE_URL` environment variable to customize the database location:

```bash
DATABASE_URL="sqlite://custom_path.db?mode=rwc" 
```

Default: `sqlite://recipes.db?mode=rwc`

## Development

```bash
# Build
cargo build

# Run with release optimizations
cargo run --release
```
