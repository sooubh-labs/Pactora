# Navigation Refactor & UI De-cluttering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the app's navigation by moving secondary features from the Dashboard and Bottom Navigation into a new "More" menu and adding a placeholder Profile screen.

**Architecture:** 
- Add a new `MoreScreen` and `ProfileScreen` in the dashboard feature.
- Update `GoRouter` configuration in `router.dart` to include these new screens.
- Modify `MainShell` to replace the "People" tab with "More" and update indexing logic.
- Clean up `DashboardScreen` by removing redundant AppBar actions.

**Tech Stack:** Flutter, Riverpod, GoRouter, Material Design 3.

---

### Task 1: Create Profile and More Screens

**Files:**
- Create: `lib/features/dashboard/presentation/profile_screen.dart`
- Create: `lib/features/dashboard/presentation/more_screen.dart`

- [ ] **Step 1: Create ProfileScreen placeholder**

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('User Profile Screen (Placeholder)'),
      ),
    );
  }
}
```

- [ ] **Step 2: Create MoreScreen with list items**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          _buildProfileHeader(context),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('People'),
            onTap: () => context.push('/people'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () => context.push('/calendar'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () => context.push('/stats'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Activity'),
            onTap: () => context.push('/timeline'),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archive'),
            onTap: () => context.push('/archive'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, size: 40, color: Colors.grey),
      ),
      title: const Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('View and edit profile'),
      onTap: () => context.push('/profile'),
    );
  }
}
```

- [ ] **Step 3: Commit new screens**

```bash
git add lib/features/dashboard/presentation/profile_screen.dart lib/features/dashboard/presentation/more_screen.dart
git commit -m "feat: add ProfileScreen and MoreScreen"
```

---

### Task 2: Update Router Configuration

**Files:**
- Modify: `lib/app/router.dart`

- [ ] **Step 1: Import new screens**

```dart
import '../features/dashboard/presentation/more_screen.dart';
import '../features/dashboard/presentation/profile_screen.dart';
```

- [ ] **Step 2: Add routes to ShellRoute**

```dart
// Inside ShellRoute routes list
        GoRoute(
          path: '/more',
          builder: (context, state) => const MoreScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
```

- [ ] **Step 3: Verify router compiles**

Run: `flutter pub run build_runner build --delete-conflicting-outputs` (if needed for g.dart files, though router doesn't use them directly)
Just check for syntax errors in IDE or run a build.

- [ ] **Step 4: Commit router changes**

```bash
git add lib/app/router.dart
git commit -m "feat: add /more and /profile routes"
```

---

### Task 3: Refactor MainShell Navigation

**Files:**
- Modify: `lib/app/main_shell.dart`

- [ ] **Step 1: Update NavigationDestination list**

Replace 'People' with 'More'.

```dart
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Promises'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finances'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
```

- [ ] **Step 2: Update _getSelectedIndex logic**

```dart
  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/promises')) return 1;
    if (location.startsWith('/finances') ||
        location.startsWith('/money') ||
        location.startsWith('/borrow')) return 3;
    if (location.startsWith('/more') || 
        location.startsWith('/people') ||
        location.startsWith('/calendar') ||
        location.startsWith('/timeline') ||
        location.startsWith('/stats') ||
        location.startsWith('/archive') ||
        location.startsWith('/settings') ||
        location.startsWith('/profile')) return 4;
    return 0;
  }
```

- [ ] **Step 3: Update _onItemTapped logic**

```dart
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/promises');
        break;
      case 3:
        context.go('/finances');
        break;
      case 4:
        context.go('/more');
        break;
    }
  }
```

- [ ] **Step 4: Commit MainShell changes**

```bash
git add lib/app/main_shell.dart
git commit -m "refactor: replace People tab with More in MainShell"
```

---

### Task 4: Clean up Dashboard AppBar

**Files:**
- Modify: `lib/features/dashboard/presentation/dashboard_screen.dart`

- [ ] **Step 1: Simplify AppBar actions**

Remove all icons except Search.

```dart
      appBar: AppBar(
        title: const Text('Pactora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
```

- [ ] **Step 2: Commit Dashboard changes**

```bash
git add lib/features/dashboard/presentation/dashboard_screen.dart
git commit -m "refactor: clean up Dashboard AppBar actions"
```

---

### Task 5: Final Verification

- [ ] **Step 1: Verify all routes from More screen**
- [ ] **Step 2: Verify Bottom Navigation index highlights correctly for all sub-routes of 'More'**
- [ ] **Step 3: Run existing tests to ensure no regressions**

Run: `flutter test`
