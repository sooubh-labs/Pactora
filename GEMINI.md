# Pactora Project Guidelines

## 🎯 Architectural Intent
Pactora is a modular, feature-first Flutter application. Logic is decentralized into features, while infrastructure (DB, Theme, Services) is centralized in `lib/core`.

## 🛠 Tech Stack & Conventions
- **Flutter SDK:** Min version 3.19.0.
- **State Management:** Riverpod 2 with code generation. Functional providers preferred.
- **Database:** Isar 3. Always handle initialization in `main.dart` with error recovery.
- **Routing:** GoRouter in `lib/app/router.dart`. Use declarative paths.
- **Styling:** Strict adherence to `AppColors` and `AppTheme`.

## 🏗 Workflow
- **Code Generation:** Always run `dart run build_runner build --delete-conflicting-outputs` when modifying domain models or providers.
- **Documentation:** Maintain `AGENTS.md` for AI instructions and `PROJECT.md` for status.
- **Git:** Use conventional commits. Never commit secrets.

## 📜 Quality Standards
- **Compatibility:** No `.withValues()`. Use `.withOpacity()`.
- **Layout:** Use `Gap` for spacing. `ElevatedButton` must not have infinite width inside `Row`.
- **Offline:** 100% offline functionality is mandatory. No cloud dependencies.
