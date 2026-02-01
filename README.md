# Repoli (Rezepte & Posti-Liste)

A full-stack application for recipes and a shopping list with a Rust backend (Axum + SQLx) and Flutter frontend.

For more details, see the README files in each directory:
- [Backend README](backend/README.md)
- [Frontend README](frontend/README.md)

## Project Structure

```
repoli/
├── backend/         # Rust API server
│   ├── src/         # Rust source code
│   ├── migrations/  # Database migrations
│   └── Cargo.toml   # Rust dependencies
└── frontend/        # Flutter mobile/web app
    ├── lib/         # Dart source code
    ├── web/         # Web assets
    └── pubspec.yaml # Flutter dependencies
```

## Features

- **Backend (Rust)**
  - RESTful API with Axum
  - SQLite database with SQLx
  - Automatic migrations
  - CORS enabled for frontend

- **Frontend (Flutter)**
  - View all recipes in scrollable list
  - Create new recipes with form
  - View recipe details
  - Pull-to-refresh
  - Responsive Material Design UI

## Getting Started

### Prerequisites
- Rust (latest stable)
- Flutter SDK
- SQLite

### Running the Application

```bash
./start.sh
```
