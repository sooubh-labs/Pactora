# Dark Theme & UI Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a functional dark theme, theme switching settings, and fix subscription/UI inconsistencies.

**Architecture:** Use Riverpod for theme state management, SharedPreferences for persistence, and Material 3's built-in support for multiple themes.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, in_app_purchase.

---

### Task 1: Update Theme Persistence

**Files:**
- Modify: `lib/core/providers/user_preferences_provider.dart`

- [ ] **Step 1: Add ThemeMode to UserPreferences model**
Update the class to include `themeMode`.

```dart
enum AppThemeMode { system, light, dark }

class UserPreferences {
  // ... existing fields
  final AppThemeMode themeMode;

  UserPreferences({
    // ...
    required this.themeMode,
  });

  UserPreferences copyWith({
    // ...
    AppThemeMode? themeMode,
  }) {
    return UserPreferences(
      // ...
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
```

- [ ] **Step 2: Update UserPreferencesNotifier to handle ThemeMode**
Add key, default value, and persistence methods.

```dart
class UserPreferencesNotifier extends Notifier<UserPreferences> {
  static const _keyThemeMode = 'theme_mode';

  @override
  UserPreferences build() {
    _loadFromPrefs();
    return UserPreferences(
      // ... default values
      themeMode: AppThemeMode.system,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyThemeMode) ?? 0;
    state = state.copyWith(
      // ...
      themeMode: AppThemeMode.values[themeIndex],
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    state = state.copyWith(themeMode: mode);
  }
}
```

- [ ] **Step 3: Commit**
```bash
git add lib/core/providers/user_preferences_provider.dart
git commit -m "feat: add theme mode persistence to user preferences"
```

### Task 2: Implement Dark Theme Palette

**Files:**
- Modify: `lib/core/theme/app_colors.dart`
- Modify: `lib/core/theme/app_theme.dart`

- [x] **Step 1: Define Dark Palette in AppColors**
Add a nested class or static constants for dark mode.

```dart
class AppColors {
  // ... existing light colors
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF334155);
}
```

- [x] **Step 2: Implement buildDarkTheme in AppTheme**
Create the `darkTheme` getter and update `buildDarkTheme`.

```dart
static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary, // Use a lighter primary for dark mode
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
    ),
    // ... copy appropriate themes from lightTheme and adjust colors
    appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimaryDark,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
  );
}
```

- [x] **Step 3: Commit**
```bash
git add lib/core/theme/app_colors.dart lib/core/theme/app_theme.dart
git commit -m "feat: implement dark theme palette and theme builder"
```

### Task 3: Link Theme to App Root

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update PactoraApp to listen to themeMode**
Map `AppThemeMode` to Flutter's `ThemeMode`.

```dart
class PactoraApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(userPreferencesProvider.select((p) => p.themeMode));
    
    ThemeMode flutterThemeMode;
    switch (themeMode) {
      case AppThemeMode.light: flutterThemeMode = ThemeMode.light; break;
      case AppThemeMode.dark: flutterThemeMode = ThemeMode.dark; break;
      default: flutterThemeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      // ...
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: flutterThemeMode,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/main.dart
git commit -m "feat: connect theme mode provider to MaterialApp"
```

### Task 4: Update Settings UI

**Files:**
- Modify: `lib/features/settings/presentation/settings_screen.dart`

- [ ] **Step 1: Implement Theme Selector Dialog**
Change the theme ListTile to open a selection dialog.

```dart
ListTile(
  leading: const Icon(Icons.brightness_6),
  title: const Text('Theme Mode'),
  trailing: Text(prefs.themeMode.name.toUpperCase()),
  onTap: () => _showThemeDialog(context, ref),
),

void _showThemeDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) => RadioListTile<AppThemeMode>(
          title: Text(mode.name.toUpperCase()),
          value: mode,
          groupValue: ref.watch(userPreferencesProvider).themeMode,
          onChanged: (val) {
            if (val != null) {
              ref.read(userPreferencesProvider.notifier).setThemeMode(val);
              Navigator.pop(context);
            }
          },
        )).toList(),
      ),
    ),
  );
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/features/settings/presentation/settings_screen.dart
git commit -m "feat: add theme mode selector to settings screen"
```

### Task 5: Component Polish (Stats & Calendar)

**Files:**
- Modify: `lib/features/dashboard/presentation/stats_screen.dart`
- Modify: `lib/shared/widgets/horizontal_calendar.dart`

- [ ] **Step 1: Make Stats cards theme-aware**
Remove hardcoded `Colors.blue/green` and use `Theme.of(context).colorScheme`.

- [ ] **Step 2: Update HorizontalCalendar colors**
Replace `Colors.white` with `Theme.of(context).cardColor`.

- [ ] **Step 3: Commit**
```bash
git add lib/features/dashboard/presentation/stats_screen.dart lib/shared/widgets/horizontal_calendar.dart
git commit -m "style: make stats and calendar components theme-aware"
```

### Task 6: IAP Logic Fixes

**Files:**
- Modify: `lib/core/iap/iap_service.dart`

- [ ] **Step 1: Add error feedback to IAP Service**
Catch errors and notify the user.

```dart
// In _onPurchaseUpdate
if (purchaseDetails.status == PurchaseStatus.error) {
  debugPrint('Purchase Error: ${purchaseDetails.error}');
  // We'll need a way to show a snackbar. Since IapService is a Provider, 
  // we might want to use a global key or a separate UI state provider.
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/core/iap/iap_service.dart
git commit -m "fix: add error logging to IAP service"
```
