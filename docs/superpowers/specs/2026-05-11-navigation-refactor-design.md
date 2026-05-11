# Design Document: Navigation Refactor & UI De-cluttering

This document outlines the design for refactoring the app's navigation and cleaning up the home page (Dashboard) by consolidating secondary features into a new "More" menu.

## 1. Problem Statement
The current Dashboard screen is cluttered with too many AppBar actions (Calendar, Stats, Timeline, Archive, Search, Settings). Additionally, the bottom navigation is reaching its limit, and there is a need to organize the app's features more logically to improve user experience and scalability.

## 2. Proposed Solution
- Replace the "People" tab in the bottom navigation with a "More" tab.
- Create a new `MoreScreen` that acts as a central hub for secondary features.
- Clean up the `DashboardScreen` AppBar by moving most actions into the `MoreScreen`.
- Introduce a placeholder `ProfileScreen` for future user profile management.

## 3. Architecture & Components

### 3.1. Navigation Changes
- **MainShell:** Update `NavigationBar` to replace the "People" destination with "More".
- **Router:** 
    - Add `/more` route for `MoreScreen`.
    - Add `/profile` route for `ProfileScreen`.
    - Update selected index logic in `MainShell`.

### 3.2. New Screens
- **MoreScreen (`lib/features/dashboard/presentation/more_screen.dart`):**
    - A `ListView` containing:
        - **Profile Header:** A custom widget at the top linking to the Profile screen.
        - **People:** Navigates to `/people`.
        - **Calendar:** Navigates to `/calendar`.
        - **Reports (Stats):** Navigates to `/stats`.
        - **Activity (Timeline):** Navigates to `/timeline`.
        - **Archive:** Navigates to `/archive`.
        - **Settings:** Navigates to `/settings`.
- **ProfileScreen (`lib/features/dashboard/presentation/profile_screen.dart`):**
    - A simple placeholder screen with an AppBar and a centered message.

### 3.3. Dashboard Cleanup
- **DashboardScreen:** Remove AppBar icons for Calendar, Stats, Timeline, Archive, and Settings.
- Keep the **Search** icon in the AppBar for quick access.

## 4. Implementation Details

### MainShell Update
```dart
destinations: const [
  NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
  NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Promises'),
  NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
  NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finances'),
  NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'), // Changed from People
],
```

### MoreScreen Structure
```dart
class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('More')),
      body: ListView(
        children: [
          _ProfileHeader(),
          ListTile(leading: Icon(Icons.people_outline), title: Text('People'), onTap: () => context.push('/people')),
          ListTile(leading: Icon(Icons.calendar_month), title: Text('Calendar'), onTap: () => context.push('/calendar')),
          ListTile(leading: Icon(Icons.bar_chart), title: Text('Reports'), onTap: () => context.push('/stats')),
          ListTile(leading: Icon(Icons.history), title: Text('Activity'), onTap: () => context.push('/timeline')),
          ListTile(leading: Icon(Icons.archive_outlined), title: Text('Archive'), onTap: () => context.push('/archive')),
          ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: () => context.push('/settings')),
        ],
      ),
    );
  }
}
```

## 5. Testing Strategy
- **Manual Verification:** 
    - Navigate to all screens from the "More" menu to ensure routes work.
    - Check "More" tab selection state in the bottom navigation.
    - Verify Dashboard AppBar is clean.
- **Widget Tests:**
    - Update `horizontal_calendar_test.dart` if navigation changes affect it (though unlikely).
    - Add a basic test for `MoreScreen` to ensure all `ListTile`s are present.

## 6. Self-Review
- **Placeholder scan:** `ProfileScreen` is explicitly defined as a placeholder.
- **Internal consistency:** All navigation routes match the existing router structure.
- **Scope check:** This is a focused UI/Navigation refactor.
- **Ambiguity check:** The mapping of items to icons and labels is clear.
