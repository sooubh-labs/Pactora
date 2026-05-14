# Design Spec: Dark Theme & UI Polish

## Overview
Implement a comprehensive dark theme system for Pactora, add theme switching to Settings, and fix outstanding issues with subscriptions and UI inconsistencies in various elements.

## Goals
- Add a professional dark theme palette.
- Allow users to choose between Light, Dark, and System theme modes.
- Fix hardcoded colors in UI components to support dynamic theme switching.
- Improve reliability and feedback for In-App Purchases (IAP).

## Architecture

### 1. Theme Palette (`lib/core/theme/app_colors.dart`)
Define a new `AppColorsDark` class or extend `AppColors` with semantic mappings for dark mode.
- **Background:** `#0F172A` (Slate 900)
- **Surface:** `#1E293B` (Slate 800)
- **Primary:** `#818CF8` (Indigo 400)
- **Text Primary:** `#F8FAFC` (Slate 50)
- **Text Secondary:** `#94A3B8` (Slate 400)

### 2. Theme Switching Logic
- **`UserPreferences`**: Add `ThemeMode themeMode` field (enum).
- **`UserPreferencesNotifier`**: Handle persistence of `themeMode` in `SharedPreferences`.
- **`PactoraApp` (`lib/main.dart`)**: Listen to `userPreferencesProvider` and update `MaterialApp.router`'s `themeMode` property.

### 3. Settings UI (`lib/features/settings/presentation/settings_screen.dart`)
- Replace the static "System" text in the Theme Mode ListTile with a functional selector.
- Show a dialog or bottom sheet to select between "System", "Light", and "Dark".

### 4. Component Refactoring (UI Polish)
- **`StatsScreen`**: Replace hardcoded `Colors.blue`, `Colors.green`, etc., with semantic colors from `Theme.of(context).colorScheme`.
- **`HorizontalCalendar`**: 
    - Remove hardcoded `Colors.white` for the card background.
    - Adjust shadow colors to be less intense in dark mode.
- **`PremiumScreen`**: Fix hardcoded white cards and indigo borders to adapt to dark theme.

### 5. Subscription Fixes (`lib/core/iap/iap_service.dart`)
- **Error Handling**: Add `ScaffoldMessenger` feedback when a purchase fails or is cancelled.
- **State Sync**: Ensure `isPremiumProvider` updates immediately after `_iap.completePurchase`.
- **Restoration**: Log results of `restorePurchases` and notify user if no purchases were found.

## Verification Plan
1. Toggle between Light, Dark, and System themes in Settings.
2. Verify all screens (Dashboard, Stats, Calendar, Settings) adapt correctly without unreadable text.
3. Test IAP flow (using test IDs) and ensure the "Premium" status is reflected immediately.
4. Verify theme preference persists after app restart.
