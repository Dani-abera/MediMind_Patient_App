# Architecture

## Overview

MediMind follows **Clean Architecture** with a feature-first folder structure. Each feature is a self-contained vertical slice with its own domain, data, and presentation layers, registered via a dedicated injection file.

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── cache/               # Hive TTL cache
│   ├── connectivity/        # ConnectivityCubit + offline banner
│   ├── constants/           # App-wide constants
│   ├── di/                  # GetIt service locator
│   ├── error/               # Failure types + error handler
│   ├── extensions/          # Dart extensions
│   ├── network/             # Dio client, interceptors, SSL pinning
│   ├── routing/             # go_router configuration
│   ├── security/            # Root/jailbreak detection
│   ├── services/            # Analytics, Crashlytics, RemoteConfig, Push
│   ├── storage/             # Hive + SharedPreferences wrappers
│   ├── theme/               # AppColors, AppTypography, AppTheme
│   ├── utils/               # Formatters, validators, helpers
│   └── widgets/             # Reusable UI components
│
└── features/                # Feature modules
    ├── auth/
    ├── appointments/
    ├── booking/
    ├── centers/
    ├── doctors/
    ├── emergency_contacts/
    ├── favorites/
    ├── health/
    ├── health_records/
    ├── home/
    ├── medical_history/
    ├── medication_reminders/
    ├── notifications/
    ├── payments/
    ├── predictions/
    ├── prescriptions/
    ├── profile/
    ├── queue/
    ├── reviews/
    ├── settings/
    └── video_consultation/
```

## Feature Structure

Each feature follows this layout:

```
feature/
├── data/
│   ├── datasources/         # Remote (Dio) and local (Hive) data sources
│   ├── models/              # JSON-serializable DTOs extending domain entities
│   └── repositories/        # Repository implementations
│
├── domain/
│   ├── entities/            # Pure Dart business objects (Equatable)
│   ├── repositories/        # Abstract repository interfaces
│   └── usecases/            # Single-responsibility use cases
│
├── presentation/
│   ├── bloc/                # BLoC/Cubit event+state+bloc files
│   ├── pages/               # Full-screen widgets (routed)
│   └── widgets/             # Feature-specific reusable widgets
│
└── feature_injection.dart   # GetIt registrations for this feature
```

## Dependency Flow

```
presentation → domain ← data
                ↑
              core
```

- **Presentation** depends only on domain (use cases + entities)
- **Data** depends only on domain (implements repository interfaces)
- **Domain** has no dependencies on Flutter or external packages
- **Core** is shared across all layers

## State Management

BLoC pattern throughout:

- **Bloc**: complex event-driven state (appointments, predictions, auth)
- **Cubit**: simpler state with direct method calls (connectivity, settings)
- `bloc_concurrency` transformers (`restartable()`, `droppable()`, `sequential()`) prevent race conditions

## Dependency Injection

GetIt with lazy singletons for services and factories for BLoCs:

```dart
// Service (singleton)
sl.registerLazySingleton<DioClient>(() => DioClient(sl()));

// BLoC (factory — new instance per route)
sl.registerFactory<AppointmentsBloc>(() => AppointmentsBloc(useCase: sl()));
```

## Navigation

`go_router` with:

- `StatefulShellRoute` for bottom-nav tabs (Home, Book, Health, Profile)
- `ShellRoute` for OTP auth flow (shared OtpBloc scope)
- Named routes via `RouteNames` constants
- Global redirect based on `AuthBloc` state (Authenticated/Unauthenticated/Unregistered)

## Networking

Dio with layered interceptors:

1. `SslPinningInterceptor` — certificate pinning (release only)
2. `AuthInterceptor` — injects Bearer token, handles 401 refresh
3. `ErrorInterceptor` — maps HTTP errors to typed `Failure` objects
4. `LoggerInterceptor` — pretty-prints requests/responses (debug only)

## Caching

Hive TTL cache (`HiveCache`) for GET responses:

| Endpoint | TTL |
|----------|-----|
| Centers | 5 min |
| Doctors | 5 min |
| Slot availability | 30 sec |
| AI predictions | 10 min |

## Analytics & Observability

- **Firebase Analytics**: screen views (via `AnalyticsRouteObserver`) + domain events
- **Firebase Crashlytics**: release-only; hashed user ID; custom keys for screen + feature flags
- **Firebase Remote Config**: feature flags, force/flexible update thresholds, maintenance mode
