# Repoli Frontend

Flutter application for viewing and creating recipes.

## Features
- View all recipes in a scrollable list
- Tap any recipe to see full details
- Create new recipes with a simple form
- Pull-to-refresh to reload recipes
- Clean, modern UI with Material Design
- Cross-platform: Web, iOS, Android, Desktop

## Prerequisites
- Flutter SDK
- Dart SDK
- Running backend server on `http://localhost:3000`

## Project Structure
```
frontend/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── api_service.dart           # HTTP client for backend
│   ├── recipe_list_screen.dart    # Main recipes list
│   ├── recipe_detail_screen.dart  # Single recipe view
│   └── create_recipe_screen.dart  # New recipe form
├── web/                           # Web assets
├── pubspec.yaml                   # Dependencies
└── README.md
```

## Running

1. Make sure the backend is running:
```bash
cd ../backend
cargo run
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For mobile (Android/iOS)
flutter run

# For desktop
flutter run -d macos  # or linux/windows
```

## Configuration

The API endpoint is set to `http://localhost:3000` in `lib/api_service.dart`. 

To change the backend URL, edit the `baseUrl` variable:
```dart
final String baseUrl = 'http://localhost:3000';
```

## Building for Production

```bash
# Web
flutter build web

# Android
flutter build apk

# iOS (requires macOS)
flutter build ios

# Desktop
flutter build linux    # or macos/windows
```
