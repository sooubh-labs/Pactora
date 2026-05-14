# 04. Technical Architecture — Pactora

## Technology Stack
- **Language:** Dart 3.x
- **UI Framework:** Flutter 3.19.x (Material 3)
- **Database:** Isar 3.1.x (High-performance NoSQL)
- **State Management:** Riverpod 2.x (with `riverpod_generator`)
- **Navigation:** GoRouter 13.x (Declarative)
- **Notifications:** `flutter_local_notifications` + `timezone`

## Architecture Pattern: Feature-First
The project follows a modified Clean Architecture approach, organized by **Features**:

```text
lib/features/[feature_name]/
├── domain/       # Isar Models, Enums
├── data/         # Repositories (if complex), Isar Query Logic
└── presentation/ # Widgets, Screens, Riverpod Notifiers
```

## State Management Strategy
We use **Riverpod** for all business logic:
- **Service Providers:** Global instances of `IsarService`, `NotificationService`, and `AdService`.
- **List Providers:** `StreamProvider` wrappers around Isar collection watchers. This ensures the UI is reactive to database changes without manual refreshing.
- **Detail Providers:** `FutureProvider.family` to fetch specific records by ID.
- **Notifier Classes:** For complex state mutations (e.g., adding a payment and updating a record status).

## Database Service (`IsarService`)
A singleton service that manages:
- **Initialization:** Opening the Isar instance with all schemas.
- **CRUD Operations:** Generic and specific methods for data persistence.
- **Watchers:** Providing streams for real-time UI updates.

## Notification Service (`NotificationService`)
Handles local scheduling:
- Mapping `Promise` or `Item` IDs to unique notification IDs.
- Handling timezone-aware scheduling.
- Payload management to navigate to specific screens when a notification is tapped.

## Offline Storage
- **Database:** `isar_flutter_libs` handles native binary storage.
- **Photos:** `path_provider` locates `getApplicationDocumentsDirectory()`. The `ImageService` manages copying files from the cache (after picking) to this permanent local directory.
