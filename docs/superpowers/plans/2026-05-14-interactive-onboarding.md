# Interactive Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a first-time user experience with dummy data and an interactive visual tour of the dashboard.

**Architecture:** 
- A `DataSeedService` for injecting initial Isar data.
- A `GuideService` to manage the "tour shown" state.
- A `FeatureGuide` overlay widget for the interactive tour.

**Tech Stack:** Flutter, Isar, SharedPreferences, Riverpod.

---

### Task 1: Create Data Seeding Service

**Files:**
- Create: `lib/core/services/data_seed_service.dart`

- [ ] **Step 1: Implement DataSeedService**

```dart
import 'package:isar/isar.dart';
import '../services/isar_service.dart';
import '../../features/people/domain/person_model.dart';
import '../../features/promises/domain/promise_model.dart';
import '../../features/promises/domain/promise_enums.dart';
import '../../features/borrow/domain/item_model.dart';
import '../../features/money/domain/money_model.dart';

class DataSeedService {
  static Future<void> seed() async {
    final db = IsarService.db;
    
    // Check if already seeded or has data
    final count = await db.people.count();
    if (count > 0) return;

    await db.writeTxn(() async {
      // 1. Seed People
      final sarah = Person()..name = 'Sarah'..colorValue = 0xFF8B5CF6;
      final john = Person()..name = 'John'..colorValue = 0xFF0EA5E9;
      await db.people.putAll([sarah, john]);

      // 2. Seed Promise
      final promise = Promise()
        ..title = 'Call Sarah about the trip'
        ..personId = sarah.id
        ..category = 'Task'
        ..priority = PromisePriority.medium
        ..status = PromiseStatus.pending
        ..dueDate = DateTime.now().add(const Duration(days: 2));
      await db.promises.put(promise);

      // 3. Seed Borrow
      final borrow = BorrowItem()
        ..name = 'Clean Code Book'
        ..personId = john.id
        ..iLent = true
        ..status = ItemStatus.active
        ..expectedReturn = DateTime.now().add(const Duration(days: 7));
      await db.borrowItems.put(borrow);

      // 4. Seed Money
      final money = MoneyRecord()
        ..description = 'Dinner at Italian Place'
        ..personId = sarah.id
        ..amount = 20.0
        ..isOwedToMe = false
        ..status = MoneyStatus.pending
        ..dueDate = DateTime.now().add(const Duration(days: 1));
      await db.moneyRecords.put(money);
    });
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `flutter analyze`
Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/data_seed_service.dart
git commit -m "feat: add DataSeedService for first-time user data"
```

---

### Task 2: Create Guide Service

**Files:**
- Create: `lib/core/services/guide_service.dart`

- [ ] **Step 1: Implement GuideService**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class GuideService {
  static const String _key = 'guide_shown';

  static Future<bool> shouldShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/core/services/guide_service.dart
git commit -m "feat: add GuideService to track tour status"
```

---

### Task 3: Implement Feature Guide Widget

**Files:**
- Create: `lib/shared/widgets/feature_guide.dart`

- [ ] **Step 1: Implement FeatureGuide overlay**

```dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GuideStep {
  final GlobalKey targetKey;
  final String title;
  final String description;

  GuideStep({required this.targetKey, required this.title, required this.description});
}

class FeatureGuide extends StatefulWidget {
  final List<GuideStep> steps;
  final VoidCallback onComplete;

  const FeatureGuide({super.key, required this.steps, required this.onComplete});

  @override
  State<FeatureGuide> createState() => _FeatureGuideState();
}

class _FeatureGuideState extends State<FeatureGuide> {
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStepIndex];
    final RenderBox? renderBox = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay with hole
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Positioned(
                  left: offset.dx - 8,
                  top: offset.dy - 8,
                  child: Container(
                    width: size.width + 16,
                    height: size.height + 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Instruction Bubble
          Positioned(
            left: 24,
            right: 24,
            top: offset.dy + size.height + 24,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Gap(8),
                  Text(
                    step.description,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const Gap(24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onComplete,
                        child: const Text('Skip'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStepIndex < widget.steps.length - 1) {
                            setState(() => _currentStepIndex++);
                          } else {
                            widget.onComplete();
                          }
                        },
                        child: Text(_currentStepIndex == widget.steps.length - 1 ? 'Finish' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/shared/widgets/feature_guide.dart
git commit -m "feat: implement FeatureGuide overlay widget"
```

---

### Task 4: Integrate Data Seeding and Interactive Guide

**Files:**
- Modify: `lib/features/dashboard/presentation/onboarding_screen.dart`
- Modify: `lib/features/dashboard/presentation/dashboard_screen.dart`

- [ ] **Step 1: Call DataSeedService in OnboardingScreen**

```dart
// lib/features/dashboard/presentation/onboarding_screen.dart
// Import DataSeedService
import '../../../core/services/data_seed_service.dart';

// In _nextPage() method, before context.go('/permissions')
await DataSeedService.seed();
```

- [ ] **Step 2: Add GlobalKeys to DashboardScreen elements**

```dart
// lib/features/dashboard/presentation/dashboard_screen.dart
final GlobalKey _statsKey = GlobalKey();
final GlobalKey _activityKey = GlobalKey();
// Add these keys to the relevant widgets in build()
```

- [ ] **Step 3: Trigger FeatureGuide in DashboardScreen**

```dart
// lib/features/dashboard/presentation/dashboard_screen.dart
// Import GuideService and FeatureGuide
// Check shouldShowGuide in initState or via a post-frame callback
```

- [ ] **Step 4: Final verification and commit**

```bash
git add lib/features/dashboard/presentation/onboarding_screen.dart lib/features/dashboard/presentation/dashboard_screen.dart
git commit -m "feat: integrate interactive guide and data seeding"
```
