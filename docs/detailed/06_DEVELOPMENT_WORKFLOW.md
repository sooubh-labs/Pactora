# 06. Development & Release Workflow — Pactora

## Development Environment
- **SDK:** Flutter >= 3.19.0
- **Tools:** VS Code or Android Studio.
- **Build Runner:** `dart run build_runner build` must be run after any model or provider changes.

## Local Setup
1. Clone repository.
2. `flutter pub get`.
3. `dart run build_runner build --delete-conflicting-outputs`.
4. Ensure an Android Emulator or Device is connected.
5. `flutter run`.

## Coding Standards
- **Linting:** Follows `analysis_options.yaml` (based on `flutter_lints`).
- **Naming:** CamelCase for classes, snake_case for files, lowerCamelCase for variables.
- **Documentation:** Use `///` for public-facing methods and providers.

## Release Process
1. **Version Bump:** Update `pubspec.yaml` (e.g., `1.0.1+2`).
2. **Build AAB:** `flutter build appbundle --release`.
3. **Internal Test:** Upload to Google Play Console "Internal Testing" track.
4. **Verification:** Test on at least 3 physical devices with different screen sizes.
5. **Promotion:** Promote to Production after 48 hours of stable internal testing.

## CI/CD (GitHub Actions)
- **Workflow:** `.github/workflows/ci.yml`
- **Tasks:**
  - Check formatting (`flutter format --set-exit-if-changed .`).
  - Run Linter (`flutter analyze`).
  - Run Unit/Widget Tests (`flutter test`).
  - (Optional) Build APK for review.
