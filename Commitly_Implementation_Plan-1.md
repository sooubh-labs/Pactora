# Commitly — Full Implementation Plan
> Track promises, borrowed items, and informal commitments — fully offline.

---

## 1. Tech Stack (Final Choices)

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter 3.x | Cross-platform, fast, you know it |
| State | Riverpod 2.x + riverpod_annotation | Clean, codegen-based, scales well |
| Database | Isar 3.x | Offline-native, indexed queries, fast, supports attachments metadata |
| Notifications | flutter_local_notifications | 100% offline scheduling |
| Navigation | GoRouter | Declarative, deep-link ready |
| Media | image_picker + path_provider | Local image storage |
| Backup | file_picker + dart:convert | JSON export/import, no cloud |
| Search | Isar query indexes | Built-in, no extra package needed |
| Encryption (Premium) | encrypt + flutter_secure_storage | AES-256 for backup files |

---

## 2. Project Structure

```
commitly/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart                  # ProviderScope + MaterialApp.router
│   │   └── router.dart               # GoRouter all routes
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData light + dark
│   │   │   └── app_colors.dart       # Brand color constants
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Strings, durations, sizes
│   │   │   └── category_constants.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── format_utils.dart     # ₹ formatting, relative time
│   │   │   └── notification_utils.dart
│   │   └── services/
│   │       ├── isar_service.dart     # DB singleton
│   │       ├── notification_service.dart
│   │       └── backup_service.dart
│   ├── features/
│   │   ├── dashboard/
│   │   │   └── presentation/
│   │   │       ├── dashboard_screen.dart
│   │   │       ├── dashboard_provider.dart
│   │   │       └── widgets/
│   │   │           ├── summary_card.dart
│   │   │           ├── overdue_banner.dart
│   │   │           └── today_commitments_list.dart
│   │   ├── promises/
│   │   │   ├── data/
│   │   │   │   └── promise_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── promise_model.dart    # Isar collection
│   │   │   │   └── promise_enums.dart
│   │   │   └── presentation/
│   │   │       ├── promises_screen.dart
│   │   │       ├── add_promise_screen.dart
│   │   │       ├── promise_detail_screen.dart
│   │   │       └── promise_provider.dart
│   │   ├── borrow/
│   │   │   ├── data/
│   │   │   │   └── item_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── item_model.dart
│   │   │   └── presentation/
│   │   │       ├── borrow_screen.dart
│   │   │       ├── add_item_screen.dart
│   │   │       └── item_provider.dart
│   │   ├── money/
│   │   │   ├── data/
│   │   │   │   └── money_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── money_model.dart
│   │   │   └── presentation/
│   │   │       ├── money_screen.dart
│   │   │       ├── add_money_screen.dart
│   │   │       └── money_provider.dart
│   │   ├── people/
│   │   │   ├── data/
│   │   │   │   └── person_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── person_model.dart
│   │   │   └── presentation/
│   │   │       ├── people_screen.dart
│   │   │       ├── add_person_screen.dart
│   │   │       ├── person_detail_screen.dart
│   │   │       └── person_provider.dart
│   │   ├── search/
│   │   │   └── presentation/
│   │   │       ├── search_screen.dart
│   │   │       └── search_provider.dart
│   │   └── settings/
│   │       └── presentation/
│   │           ├── settings_screen.dart
│   │           ├── backup_screen.dart
│   │           └── reminder_settings_screen.dart
│   └── shared/
│       └── widgets/
│           ├── empty_state.dart
│           ├── person_avatar.dart
│           ├── status_chip.dart
│           ├── quick_add_sheet.dart      # Bottom sheet for fast capture
│           └── reminder_picker.dart
├── android/
├── pubspec.yaml
└── README.md
```

---

## 3. pubspec.yaml (Complete)

```yaml
name: commitly
description: Track promises, borrowed items, and informal commitments — fully offline.
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # Navigation
  go_router: ^13.0.0

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Database (offline-first)
  isar: ^3.1.0
  isar_flutter_libs: ^3.1.0  # contains native libs
  path_provider: ^2.1.0

  # Notifications
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.2

  # Media / Attachments
  image_picker: ^1.1.0
  cached_network_image: ^3.3.0  # for local file rendering

  # File / Backup
  file_picker: ^8.0.0
  share_plus: ^9.0.0

  # UI
  gap: ^3.0.1
  google_fonts: ^6.2.0
  flutter_slidable: ^3.1.0     # swipe actions on list items
  intl: ^0.19.0

  # Utils
  uuid: ^4.4.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  isar_generator: ^3.1.0
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#1A1A2E"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/
```

---

## 4. Isar Database Models

### person_model.dart
```dart
import 'package:isar/isar.dart';
part 'person_model.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? phone;
  String? avatarPath;
  String? notes;
  late DateTime createdAt;

  // Computed trust score (not stored)
  // Calculated from linked promises/items
}
```

### promise_model.dart
```dart
import 'package:isar/isar.dart';
part 'promise_model.g.dart';

@collection
class Promise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  String? description;
  late int personId;           // FK to Person
  late String type;            // PromiseType enum value
  late String status;          // PromiseStatus enum value
  late String category;        // PromiseCategory enum value
  late String priority;        // Priority enum value

  DateTime? dueDate;
  DateTime? dueTime;
  DateTime? completedAt;
  late DateTime createdAt;

  String? notes;
  List<String> attachmentPaths = [];

  // Reminder config stored as JSON string
  String? reminderConfigJson;

  // Who made promise — direction
  late bool iMadeThisPromise;  // true = I promised; false = they promised me
}
```

### item_model.dart
```dart
import 'package:isar/isar.dart';
part 'item_model.g.dart';

@collection
class BorrowItem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? photoPath;
  late int personId;
  late bool iLent;          // true = I lent; false = I borrowed
  late String status;       // active, returned, overdue, lost
  late String condition;    // good, fair, damaged
  double? estimatedValue;
  DateTime? handoverDate;
  DateTime? expectedReturn;
  String? notes;
  late DateTime createdAt;
}
```

### money_model.dart
```dart
import 'package:isar/isar.dart';
part 'money_model.g.dart';

@collection
class MoneyRecord {
  Id id = Isar.autoIncrement;

  late int personId;
  late double amount;
  late String currency;    // 'INR', 'USD' etc.
  late bool iOwe;          // true = I owe them; false = they owe me
  late String status;      // pending, paid, partial, cancelled
  double paidAmount = 0.0;
  String? description;
  DateTime? dueDate;
  late DateTime createdAt;
}
```

---

## 5. Core Services

### isar_service.dart
```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static late Isar _isar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [PersonSchema, PromiseSchema, BorrowItemSchema, MoneyRecordSchema],
      directory: dir.path,
    );
    _initialized = true;
  }

  static Isar get db => _isar;
}
```

### notification_service.dart
```dart
// Key method signatures — implement each fully

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async { /* init android/iOS channels */ }

  // Schedule for a specific datetime (due date)
  static Future<void> schedulePromiseReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async { /* use TZDateTime */ }

  // Cancel when marked complete/cancelled
  static Future<void> cancel(int notificationId) async { }

  // Daily nag for overdue items
  static Future<void> scheduleOverdueNag(int id, String title) async { }
}
```

---

## 6. Router (GoRouter)

```dart
// router.dart
final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/dashboard',    builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/commitments',  builder: (c, s) => const PromisesScreen()),
        GoRoute(path: '/borrowed',     builder: (c, s) => const BorrowScreen()),
        GoRoute(path: '/money',        builder: (c, s) => const MoneyScreen()),
        GoRoute(path: '/people',       builder: (c, s) => const PeopleScreen()),
      ],
    ),
    GoRoute(path: '/add-promise',       builder: (c, s) => const AddPromiseScreen()),
    GoRoute(path: '/add-item',          builder: (c, s) => const AddItemScreen()),
    GoRoute(path: '/add-money',         builder: (c, s) => const AddMoneyScreen()),
    GoRoute(path: '/promise/:id',       builder: (c, s) => PromiseDetailScreen(id: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/person/:id',        builder: (c, s) => PersonDetailScreen(id: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/search',            builder: (c, s) => const SearchScreen()),
    GoRoute(path: '/settings',          builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/settings/backup',   builder: (c, s) => const BackupScreen()),
  ],
);
```

---

## 7. Theme

```dart
// app_colors.dart
class AppColors {
  // Brand
  static const primary = Color(0xFF4E75F6);
  static const primaryLight = Color(0xFF8E94F2);
  static const background = Color(0xFF1C1C3A);

  // Status colors
  static const overdue  = Color(0xFFFF5252);
  static const pending  = Color(0xFFFFB300);
  static const complete = Color(0xFF66BB6A);
  static const active   = Color(0xFF42A5F5);

  // Category colors
  static const money    = Color(0xFF26C6DA);
  static const task     = Color(0xFFAB47BC);
  static const meeting  = Color(0xFFEC407A);
  static const borrow   = Color(0xFFFF7043);
}
```

```dart
// app_theme.dart
ThemeData buildLightTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  fontFamily: GoogleFonts.poppins().fontFamily,
  cardTheme: const CardTheme(elevation: 0, shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  )),
);

ThemeData buildDarkTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    surface: AppColors.background,
  ),
  fontFamily: GoogleFonts.poppins().fontFamily,
);
```

---

## 8. Key Providers (Riverpod)

```dart
// promise_provider.dart

// All promises stream
@riverpod
Stream<List<Promise>> allPromises(AllPromisesRef ref) {
  return IsarService.db.promises
    .where()
    .sortByDueDateAsc()
    .watch(fireImmediately: true);
}

// Overdue promises
@riverpod
Stream<List<Promise>> overduePromises(OverduePromisesRef ref) {
  final now = DateTime.now();
  return IsarService.db.promises
    .filter()
    .statusEqualTo('pending')
    .dueDateLessThan(now)
    .watch(fireImmediately: true);
}

// Promises by person
@riverpod
Stream<List<Promise>> promisesByPerson(PromisesByPersonRef ref, int personId) {
  return IsarService.db.promises
    .filter()
    .personIdEqualTo(personId)
    .watch(fireImmediately: true);
}

// Dashboard summary
@riverpod
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final db = IsarService.db;
  final now = DateTime.now();
  return DashboardSummary(
    pendingCount:  await db.promises.filter().statusEqualTo('pending').count(),
    overdueCount:  await db.promises.filter().statusEqualTo('pending').dueDateLessThan(now).count(),
    activeBorrows: await db.borrowItems.filter().statusEqualTo('active').count(),
    moneyOwed:     await db.moneyRecords.filter().iOweEqualTo(false).statusEqualTo('pending').findAll()
                     .then((list) => list.fold(0.0, (sum, m) => sum + (m.amount - m.paidAmount))),
  );
}
```

---

## 9. Quick Add Bottom Sheet (Killer Feature)

```dart
// quick_add_sheet.dart
// Triggered by FAB on every tab

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Quick Add', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAddButton(icon: Icons.handshake, label: 'Promise',  color: AppColors.task,    onTap: () => context.push('/add-promise')),
              _QuickAddButton(icon: Icons.swap_horiz, label: 'Borrow',  color: AppColors.borrow,  onTap: () => context.push('/add-item')),
              _QuickAddButton(icon: Icons.currency_rupee, label: 'Money', color: AppColors.money, onTap: () => context.push('/add-money')),
              _QuickAddButton(icon: Icons.event, label: 'Meeting',      color: AppColors.meeting, onTap: () => context.push('/add-promise?type=meeting')),
            ],
          ),
          const Gap(24),
        ],
      ),
    );
  }
}
```

---

## 10. One-Tap Reminder Message Generator

```dart
// format_utils.dart

String generateReminderMessage(Promise promise, String personName) {
  final category = promise.category;
  final dueText = promise.dueDate != null
    ? 'by ${DateFormat('EEE, MMM d').format(promise.dueDate!)}'
    : 'soon';

  switch (category) {
    case 'money':
      return 'Hey $personName, just a friendly reminder about the payment 😊';
    case 'task':
      return 'Hey $personName, wanted to follow up on "${promise.title}" $dueText 🙏';
    case 'meeting':
      return 'Hey $personName, are we still on for "${promise.title}" $dueText? 😊';
    default:
      return 'Hey $personName, just a reminder about "${promise.title}" $dueText 🙂';
  }
}

// Usage: Share via share_plus
SharePlus.share(generateReminderMessage(promise, personName));
```

---

## 11. Backup System

```dart
// backup_service.dart

class BackupService {
  // Export
  static Future<String> exportToJson() async {
    final db = IsarService.db;
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'persons':  (await db.persons.where().findAll()).map((p) => p.toJson()).toList(),
      'promises': (await db.promises.where().findAll()).map((p) => p.toJson()).toList(),
      'items':    (await db.borrowItems.where().findAll()).map((i) => i.toJson()).toList(),
      'money':    (await db.moneyRecords.where().findAll()).map((m) => m.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  // Import
  static Future<void> importFromJson(String jsonStr) async {
    final data = jsonDecode(jsonStr);
    // clear + re-insert all records
    // validate version field before importing
  }

  // Save to file and share
  static Future<void> saveAndShare() async {
    final json = await exportToJson();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/commitly_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(json);
    await SharePlus.shareXFiles([XFile(file.path)]);
  }
}
```

---

## 12. MVP Build Order (Week-by-Week)

### Week 1 — Foundation
- [ ] Flutter project setup, folder structure
- [ ] Isar models + codegen (`build_runner`)
- [ ] `IsarService.init()` in `main.dart`
- [ ] `NotificationService.init()`
- [ ] GoRouter setup
- [ ] Theme (light + dark)
- [ ] Bottom nav shell with 5 tabs

### Week 2 — Core Features
- [ ] Person model + CRUD + `PeopleScreen`
- [ ] Promise model + CRUD + `PromisesScreen`
- [ ] `AddPromiseScreen` with all fields
- [ ] Reminder scheduling on promise save
- [ ] Status update (complete / cancel)

### Week 3 — Borrow + Money
- [ ] `BorrowItem` CRUD + `BorrowScreen`
- [ ] `AddItemScreen` with photo picker
- [ ] `MoneyRecord` CRUD + `MoneyScreen`
- [ ] Partial payment tracking

### Week 4 — Dashboard + Polish
- [ ] `DashboardScreen` with summary cards
- [ ] Overdue banner
- [ ] `PersonDetailScreen` (all linked data per person)
- [ ] Quick Add bottom sheet (FAB)
- [ ] One-tap reminder message share
- [ ] `SearchScreen` with Isar queries

### Week 5 — Backup + Release Prep
- [ ] JSON backup export + import
- [ ] Settings screen
- [ ] Reminder settings (default timing, nag mode)
- [ ] Onboarding (3 slides, skip button)
- [ ] App icon (1024x1024 PNG)
- [ ] Play Store listing copy
- [ ] Signed AAB build

---

## 13. Enums Reference

```dart
// promise_enums.dart

enum PromiseStatus { pending, completed, overdue, delayed, cancelled, ignored }

enum PromiseCategory {
  money, task, meeting, callback, delivery,
  document, errand, study, personal, other
}

enum Priority { low, medium, high }

enum PromiseType { iPromised, theyPromised }

enum ItemStatus { active, returned, overdue, lost }

enum MoneyDirection { iOwe, theyOwe }
```

---

## 14. Play Store Listing (Ready to Use)

**App name:** Commitly — Promise Tracker

**Short description (80 chars):**
Track promises, borrowed items & money — 100% offline, no account needed.

**Keywords:**
promise tracker, borrow tracker, money reminder, debt reminder, commitment tracker, offline reminder, friend loan tracker, item lender

**Category:** Productivity

**Content rating:** Everyone

---

## 15. Monetization Plan (Post-MVP)

| Feature | Free | Premium (₹199 one-time) |
|---|---|---|
| Promises | Unlimited | Unlimited |
| People | Unlimited | Unlimited |
| Attachments | 3 per item | Unlimited |
| Reminders | 1 per promise | Multiple + Nag mode |
| Analytics | No | Yes |
| PDF export | No | Yes |
| Encrypted backup | No | Yes |
| Themes | 1 | 5+ |

**Package:** `in_app_purchase` (same plugin used in Lovingo)

---

## 16. Future Features (Post-Launch)

1. **Chat text parser** — Paste "return charger tomorrow" → auto-fill form (on-device, Gemini Nano or regex NLP)
2. **Trust Score** — reliability % per person, optional, shown only if enabled
3. **Widget** — Home screen glanceable: "3 things due today"
4. **Voice note attachment** — `record` package, stored locally
5. **Recurring commitments** — weekly/monthly repeat
6. **Wear OS glance** — overdue count on watch face

---

*Built with Flutter + Isar + Riverpod | 100% Offline | No account required*
