# calibrefit
# CalibreFit

A new Flutter project.
> **A production-grade Gym & Fitness mobile application** built with Flutter, Riverpod, GoRouter, and Clean Architecture.

---

## Architecture Overview

```
lib/
├── main.dart                  # Entry point — ProviderScope + AppConfig init
│
├── app/
│   ├── app.dart               # Root MaterialApp.router (ConsumerWidget)
│   ├── app_router.dart        # GoRouter + routerProvider + AppRoutes constants
│   ├── app_theme.dart         # Material 3 light/dark ThemeData
│   └── app_constants.dart     # Spacing, radius, animation, workout constants
│
├── core/
│   ├── config/                # App-level initialisation (AppConfig)
│   ├── error/                 # Sealed failure types (AppFailure hierarchy)
│   ├── network/               # Dio factory + error mapping
│   ├── storage/               # Local persistence (Drift — Phase 6+)
│   ├── notifications/         # Local/push notification service (Phase 12+)
│   ├── camera/                # Camera access for form analysis (Phase 13+)
│   └── utils/                 # Shared pure-Dart utilities
│
├── shared/
│   ├── widgets/               # AppErrorWidget, EmptyStateWidget, ...
│   ├── buttons/               # PrimaryButton, SecondaryButton, ...
│   ├── cards/                 # AppCard
│   ├── loaders/               # AppLoader
│   ├── dialogs/               # Confirmation, bottom sheets
│   └── charts/                # Progress charts (Phase 7+)
│
└── features/                  # One directory per product feature
    ├── auth/                  # Phase 1
    ├── onboarding/            # Phase 2
    ├── home/                  # Phase 3
    ├── workouts/              # Phase 5
    ├── exercise_library/      # Phase 4
    ├── set_logging/           # Phase 6
    ├── recommendations/       # Phase 9
    ├── form_analysis/         # Phase 13
    ├── diet/                  # Phase 11
    ├── progress/              # Phase 7
    ├── history/               # Phase 7
    └── profile/               # TBD
```

### Dependency Direction

```
Presentation
     |
Application / Use Case
     |
Domain
     ^
Data
```

UI widgets never call Dio, databases, or API implementations directly.

---

## Technology Stack

| Layer | Package |
|---|---|
| State management | flutter_riverpod |
| Navigation | go_router |
| Networking | dio |
| Secure storage | flutter_secure_storage |
| Models | freezed + json_serializable |
| Local DB (Phase 6+) | drift |
| AI form analysis (Phase 13+) | MediaPipe Pose Landmarker |
| Backend (Phase 14+) | FastAPI + PostgreSQL |

---

## Development Phases

| Phase | Description | Status |
|---|---|---|
| 0 | Project foundation | Complete |
| 1 | Splash + Auth navigation | Pending |
| 2 | Onboarding | Pending |
| 3 | Home dashboard | Pending |
| 4 | Exercise library | Pending |
| 5 | Active workout | Pending |
| 6 | Set logging | Pending |
| 7 | Workout history | Pending |
| 8 | Estimated 1RM | Pending |
| 9 | Weight recommendations | Pending |
| 10 | Progressive overload | Pending |
| 11 | Diet planner | Pending |
| 12 | Notifications | Pending |
| 13 | AI form analysis | Pending |
| 14 | FastAPI backend | Pending |
| 15 | Local + server sync | Pending |
| 16 | Testing | Pending |
| 17 | Polish | Pending |

---

## Getting Started

This project is a starting point for a Flutter application.
```bash
# Install dependencies
flutter pub get

A few resources to get you started if this is your first Flutter project:
# Run code generation (after adding Freezed models)
dart run build_runner build --delete-conflicting-outputs

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
# Analyse
flutter analyze

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# Test
flutter test

# Format
dart format .

# Run
flutter run
```

---

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | snake_case.dart | workout_plan_page.dart |
| Classes | PascalCase | WorkoutPlanPage |
| Methods / variables | camelCase | startWorkout() |
| Providers | featureNameProvider | activeWorkoutProvider |
| Repositories | SomethingRepository / SomethingRepositoryImpl | WorkoutRepository |

---

## Coding Rules

1. Use strongly typed Dart — avoid dynamic.
2. Keep widgets small and composable.
3. Business logic lives in providers/use-cases, not in widgets.
4. All API contracts are typed — no raw Map in presentation.
5. Planned vs actual workout data are always stored separately — never overwrite history.
6. Handle loading / error / success states explicitly.
7. Write unit tests for all non-trivial calculations.
