# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (web by default)
flutter run -d chrome

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Static analysis
flutter analyze

# Format code
dart format lib/

# Build for web
flutter build web
```

## Architecture

This is a Flutter web app for gym management (TCC FATEC project). It uses a three-layer architecture with a service locator for dependency injection.

**Stack**: Flutter + Provider (state) + GetIt (DI) + HTTP (backend at `localhost:8080`)

### Layer Structure

```
UI (pages/) → AC Services → HTTP Services → DefaultHttpClient → Backend API
```

- **`lib/backend/structure/`** — Base classes: `DefaultNotifier` (ChangeNotifier wrapper) and `IGenericoState` (state machine: `InitialState`, `LoadingState`, `SuccessState<T>`, `FailedState`)
- **`lib/backend/http/`** — `DefaultHttpClient`: thin wrapper over the `http` package with POST/GET/PUT/DELETE methods
- **`lib/backend/service/<domain>/`** — Each domain has three files:
  - `*_get_it.dart` — Registers services into GetIt (singleton or factory)
  - `ac_*_service.dart` — Application Control: business logic, sets notifier states
  - `*_http_service.dart` — Raw HTTP calls, returns parsed JSON
- **`lib/backend/notifiers/`** — Domain-specific notifiers extending `DefaultNotifier`
- **`lib/backend/models/`** — Data models with `fromJson`/`toJson`/`copyWith`/`empty()`
- **`lib/pages/`** — UI pages consuming AC services via GetIt
- **`lib/service_locator.dart`** — `setupLocator()` called at startup, registers all GetIt dependencies

### State Management Flow

1. UI calls an AC Service method
2. AC Service sets `notifier.state = LoadingState()`
3. AC Service calls HTTP Service
4. AC Service sets `notifier.state = SuccessState(data)` or `FailedState(message)`
5. UI uses `AnimatedBuilder(animation: notifier, ...)` to rebuild on state changes and renders based on state type

### Authentication

- Login POSTs to backend → response stored in `SharedPreferences` under the `"user"` key
- `CustomScaffold` checks for `"user"` on every page; missing → redirects to `LoginPage`
- API base URL is defined in `lib/backend/constants/http_constants.dart`

### Adding a New Domain

Follow the pattern in `lib/backend/service/user_services/`:
1. Create model in `lib/backend/models/`
2. Create notifier in `lib/backend/notifiers/`
3. Create `*_http_service.dart`, `ac_*_service.dart`, and `*_get_it.dart` in `lib/backend/service/<domain>/`
4. Register the new `*GetIt` in `lib/service_locator.dart`
5. Create the page in `lib/pages/` and add it to `custom_drawer.dart`
