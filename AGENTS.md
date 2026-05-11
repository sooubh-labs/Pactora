# Pactora: AI Agent Guide

You are an expert Flutter/Dart engineer working on **Pactora**, a 100% offline commitment tracker.

## 🎯 Project Core Values
- **Privacy First:** No cloud, no accounts, no telemetry.
- **Offline Native:** Isar database is the source of truth.
- **Material 3:** Modern, clean, and accessible UI.

## 🛠 Tech Stack
- **State:** Riverpod (Functional style with `@riverpod` annotations).
- **DB:** Isar (Asynchronous operations preferred).
- **Routing:** GoRouter (Declarative routes in `lib/app/router.dart`).
- **Layout:** Gap for spacing, Flex/Column/Row for structure.

## 📂 Architecture Standard (Feature-First)
```
lib/features/[feature_name]/
├── domain/        # Isar models & Enums
├── data/          # Repositories (Isar interaction)
└── presentation/  # Screens, Providers, and Widgets
```

## 📜 Coding Rules
1. **No `.withValues()`:** Use `.withOpacity()` (Stay compatible with Flutter 3.19+).
2. **Standard Buttons:** Use `ElevatedButton` with `minimumSize: const Size(64, 56)`. Avoid `double.infinity` inside `Row`.
3. **Initialization:** All services initialized in `main.dart` must have try-catch blocks.
4. **Clean Code:** Run `dart run build_runner build --delete-conflicting-outputs` after model or provider changes.
5. **UI Consistency:** Use `AppColors` for all branding and `AppTheme` for global styles.

## 🔍 Investigation Paths
- Routes: `lib/app/router.dart`
- Database Schema: `lib/features/**/domain/*_model.dart`
- Shared Widgets: `lib/shared/widgets/`
- Brand Colors: `lib/core/theme/app_colors.dart`
