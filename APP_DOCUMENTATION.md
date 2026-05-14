# Pactora — APP_DOCUMENTATION.md

---

## SECTION 1 — APP OVERVIEW
**Pactora** is a high-performance, privacy-centric mobile application built for individuals who value reliability and personal accountability. At its core, Pactora is a **100% Offline Commitment Tracker** that allows users to record, monitor, and fulfill promises, manage borrowed or lent items, and track informal financial IOUs without the need for cloud synchronization or account creation. In an era of pervasive data tracking, Pactora differentiates itself by ensuring that every piece of data—from a simple "I'll call you back" to a significant financial loan—stays exclusively on the user's device.

The app addresses the cognitive load of remembering small yet important commitments that often slip through the cracks of traditional calendars or task managers. By providing dedicated modules for **Promises**, **Borrow/Lend tracking**, and **Informal Finances**, Pactora serves as a specialized "memory assistant." Its target audience includes students, professionals, and anyone who wants to maintain a high "Trust Score" in their social and professional circles.

**Platform & Tech Stack:**
- **Framework:** Flutter (Cross-platform, primarily Android optimized)
- **State Management:** Riverpod with code generation for robust, testable logic.
- **Database:** Isar (High-performance, ACID-compliant NoSQL database for Flutter).
- **Navigation:** GoRouter for declarative, deep-link ready routing.
- **Local Services:** Native notifications via `flutter_local_notifications` and local file storage for attachments.
- **Monetization:** Hybrid model featuring Google Mobile Ads (Banners) and a one-time In-App Purchase (Pactora Plus) for advanced features.

**Current Version:** 1.0.0 (Release Candidate)
**Release Status:** Active Development / Internal Beta

---

## SECTION 2 — APP IDEA & ORIGIN
The inspiration for Pactora came from a common social friction: the "forgotten promise." Traditional tools like Google Calendar are built for time-blocked events, and Todoist is built for productivity tasks. Neither is optimized for the **relational** nature of commitments—the informal "pacts" we make with people. Whether it's returning a borrowed charger, paying back a split cab fare, or promising to send a document "by Friday," these items are often too small for a calendar but too important to forget.

Pactora addresses the gap between formal scheduling and informal memory. It acknowledges that human relationships are built on trust, and trust is maintained by keeping promises. 

**Target User Persona:**
- **The Social Student:** Frequently borrows/lends books, chargers, and small amounts of money within a hostel or campus environment. Needs a way to track who has what.
- **The Freelance Professional:** Makes numerous verbal commitments to clients ("I'll send the draft tonight") and needs a dedicated space to track these alongside their work tasks.
- **The Organized Individual:** Someone who feels anxious about forgetting small favors or debts and wants the peace of mind that a 100% private, offline tool provides.

**Market Opportunity:**
While there are "Debt Tracker" or "Inventory" apps, most are cluttered with ads, require cloud logins, or focus on a single niche. Pactora combines these into a unified, aesthetically pleasing "Personal Accountability Dashboard" that works completely offline, appealing to the growing privacy-conscious market segment.

---

## SECTION 3 — FEATURE LIST
Features are categorized by their functional domain within the app:

### [Authentication & Onboarding]
- **Zero-Auth Entry** — Use the app immediately without signing up or logging in.
- **Interactive Onboarding** — Multi-page introduction to core concepts and value propositions.
- **Permission Setup** — Transparent request flow for Notifications and Media permissions.

### [Core Functionality]
- **Promise Tracking** — Record title, person, category, and due date for any commitment.
- **Borrow & Lend Inventory** — Track physical items with condition notes and expected return dates.
- **Informal Money Records** — Manage IOUs with partial payment tracking and total owed/lent summaries.
- **People Directory** — Centralized contact list showing all linked promises and items per person.
- **Archive System** — Move completed items to an archive to keep the active list clean.

### [AI / Smart Features]
- **Activity Timeline** — A chronological feed of all creations, completions, and edits.
- **Smart Reminders** — Logic-based local notifications (e.g., 1 hour before, on due date).
- **Global Search** — Instant indexing across all modules (Promises, Items, Money, People).

### [Monetization]
- **Banner Ads** — Non-intrusive ad placements in list views for free users.
- **Pactora Plus (IAP)** — One-time upgrade to remove ads and unlock advanced features (Themes, Analytics).

### [Settings & Preferences]
- **Theme Engine** — Support for Dark, Light, and System-based themes.
- **Data Management** — Local JSON export and import for manual backups.
- **Notification Templates** — Customizable text for sharing reminders via external apps.

### [Privacy & Security]
- **100% Offline Database** — All data is stored in Isar on-device.
- **Media Privacy** — Photos are copied to the app's private documents directory.
- **Zero Tracking** — No external analytics or tracking pixels (unless user enables Ads).

---

## SECTION 4 — COMPLETE APP FLOW

### Splash Screen
- **Route / path:** `/splash`
- **Purpose:** App initialization and database boot-up.
- **Entry points:** App launch.
- **UI elements:** Animated logo, tagline.
- **Actions / interactions:** None (auto-transition).
- **Exit paths:** `/onboarding` (first run) or `/dashboard` (returning user).
- **State / data:** Isar initialization, Shared Preferences check for onboarding status.

### Onboarding Screen
- **Route / path:** `/onboarding`
- **Purpose:** Educate user on app features and privacy promise.
- **Entry points:** Splash (first run).
- **UI elements:** PageView with 5 cards, PageIndicator, "Get Started" button.
- **Actions / interactions:** Swipe pages, tap "Skip" or "Get Started".
- **Exit paths:** `/permissions`.
- **State / data:** Sets `onboarding_complete` flag to true.

### Permission Setup
- **Route / path:** `/permissions`
- **Purpose:** Request Notifications and Media permissions.
- **Entry points:** Onboarding.
- **UI elements:** Row items for each permission with "Grant" buttons.
- **Actions / interactions:** Tap "Grant", tap "Continue".
- **Exit paths:** `/dashboard`.
- **State / data:** Triggers system permission dialogs.

### Home Dashboard
- **Route / path:** `/dashboard`
- **Purpose:** High-level overview of all commitments and recent activity.
- **Entry points:** Splash, Bottom Navigation.
- **UI elements:** Summary chips (Pending, Overdue, Borrowed, Money), Section headers, Recent Activity list, FAB.
- **Actions / interactions:** Tap chips to filter, tap FAB to Quick Add, navigate via Bottom Nav.
- **Exit paths:** `/search`, `/settings`, `/promises`, `/finances`, `/people`.
- **State / data:** Real-time counts from Isar.

### Promises List
- **Route / path:** `/promises`
- **Purpose:** Manage all active and completed promises.
- **Entry points:** Bottom Nav, Dashboard chips.
- **UI elements:** TabBar (All, Pending, Overdue, Done), Filter chips, PromiseCards.
- **Actions / interactions:** Swipe to complete, tap to view details, FAB to add.
- **Exit paths:** `/promises/add`, `/promises/:id`.

### Add Promise
- **Route / path:** `/promises/add`
- **Purpose:** Create or edit a promise record.
- **Entry points:** Promises List FAB, Dashboard FAB.
- **UI elements:** Form fields (Title, Person Picker, Category Chips, Date/Time Picker, Priority).
- **Actions / interactions:** Select person, pick date, toggle "I Promised", tap Save.
- **Exit paths:** Pops back to list.
- **State / data:** Validates inputs, saves to Isar `Promise` collection.

### Promise Detail
- **Route / path:** `/promises/:id`
- **Purpose:** View details and take actions (Snooze, Complete, Share).
- **Entry points:** Promises List item tap.
- **UI elements:** Status banner, Info grid, Action buttons.
- **Actions / interactions:** Tap "Mark Complete", tap "Send Reminder" (Share), Edit icon.
- **Exit paths:** `/promises/edit/:id`.

### Finances Screen (Money & Borrow)
- **Route / path:** `/finances`
- **Purpose:** Unified view for financial and item tracking.
- **Entry points:** Bottom Nav.
- **UI elements:** Top TabBar (Money, Borrow).
- **Actions / interactions:** Switch tabs, tap items.
- **Exit paths:** `/money/:id`, `/borrow/:id`.

### People List
- **Route / path:** `/people`
- **Purpose:** Manage the directory of people involved in commitments.
- **Entry points:** Bottom Nav.
- **UI elements:** Search bar, PersonCards with activity counters.
- **Actions / interactions:** Tap to view profile, FAB to add person.
- **Exit paths:** `/people/add`, `/people/:id`.

### Settings
- **Route / path:** `/settings`
- **Purpose:** Configure app behavior, themes, and backups.
- **Entry points:** Dashboard AppBar.
- **UI elements:** List tiles (Theme, Backup, Notifications, Premium, About).
- **Actions / interactions:** Change theme, trigger JSON export/import.
- **Exit paths:** `/premium`, `/about`.

---

## SECTION 5 — TECHNICAL ARCHITECTURE

### 5.1 Project Structure
```text
lib/
├── app/                # Global config, router, and shell widget
├── core/               # Shared system-wide modules
│   ├── ads/            # AdMob service and banner components
│   ├── constants/      # App-wide strings, keys, and category lists
│   ├── iap/            # In-app purchase logic (Pactora Plus)
│   ├── providers/      # Core state providers (Preferences, etc.)
│   ├── services/       # Infrastructure (Isar, Notifications, Image, Backup)
│   └── theme/          # Material 3 theme definitions and color schemes
├── features/           # Domain-driven feature modules
│   ├── borrow/         # Item tracking (domain, data, presentation)
│   ├── dashboard/      # Home screen, splash, onboarding
│   ├── finances/       # Unified money/borrow tabs
│   ├── money/          # Cash IOU tracking
│   ├── people/         # Contact management
│   ├── promises/       # Core promise logic
│   ├── search/         # Global search indexing
│   └── settings/       # App preferences and premium UI
├── shared/             # Reusable UI widgets (Avatars, Sheets, Calendars)
└── main.dart           # Application entry point & service initialization
```

### 5.2 State Management
Pactora utilizes **Flutter Riverpod (2.x)** with code generation (`riverpod_generator`).
- **Data Flow:** UI widgets watch `@riverpod` providers. These providers interact with `IsarService` to fetch/mutate data.
- **Reactive Updates:** We use `StreamProvider` or `Notifier` to ensure the UI updates instantly when the underlying Isar database changes (using Isar's built-in watchers).
- **Structure:** Each feature has a `[feature]_provider.dart` that handles the business logic for that specific domain.

### 5.3 Database Architecture (Isar)
Pactora is **100% Offline** and does **not** use Firebase for data storage. It uses **Isar** as its primary NoSQL engine.

**Collections:**
1. **Promise**
   - Fields: `Id`, `title` (indexed), `description`, `personId` (FK), `type` (enum), `status` (enum), `category` (enum), `priority` (enum), `dueDate`, `dueTime`, `completedAt`, `createdAt`, `notes`, `attachmentPaths` (List), `iMadeThisPromise` (bool).
2. **BorrowItem**
   - Fields: `Id`, `name` (indexed), `photoPath`, `personId` (FK), `iLent` (bool), `status` (enum), `condition`, `estimatedValue`, `handoverDate`, `expectedReturn`, `notes`, `createdAt`.
3. **MoneyRecord**
   - Fields: `Id`, `personId` (FK), `amount`, `currency`, `iOwe` (bool), `photoPath`, `status` (enum), `paidAmount`, `description`, `dueDate`, `createdAt`.
4. **Person**
   - Fields: `Id`, `name` (indexed), `phone`, `email`, `avatarPath`, `notes`, `createdAt`.

**Third-Party APIs:**
- **Google Mobile Ads (AdMob):** For monetizing the free tier.
- **In-App Purchase (Google Play):** For "Pactora Plus" one-time upgrade.

### 5.4 Security Architecture
- **On-Device Only:** Data never leaves the device, eliminating server-side breach risks.
- **Local Authentication:** (Roadmap) Integration with `local_auth` for Biometric/PIN lock.
- **File Isolation:** Images are stored in the app's `getApplicationDocumentsDirectory()`, which is private to the app on Android/iOS.
- **No Analytics:** No third-party tracking (Firebase Analytics is NOT used to preserve privacy).

### 5.5 Third-Party Integrations
- `isar` (v3.1.0+1): Primary database.
- `flutter_riverpod` (v2.5.1): State management.
- `go_router` (v13.2.0): Navigation.
- `flutter_local_notifications` (v17.2.2): Local scheduling of reminders.
- `google_mobile_ads` (v5.1.0): Banner ad implementation.
- `in_app_purchase` (v3.2.0): Premium monetization.
- `share_plus` (v9.0.0): Sharing reminder text to WhatsApp/SMS.
- `image_picker` (v1.1.2): Capturing photos for items/receipts.

---

## SECTION 6 — WORKFLOW & WORK STRUCTURE

### 6.1 Development Workflow
- **Branch Strategy:** `main` (stable releases), `dev` (integration), `feature/*` (new modules).
- **Environment:** Single environment (Offline). No API keys except AdMob IDs.
- **Local Run:**
  1. `flutter pub get`
  2. `dart run build_runner build --delete-conflicting-outputs`
  3. `flutter run`

### 6.2 Release Workflow
1. Increment `version` in `pubspec.yaml`.
2. Update `CHANGELOG.md`.
3. Build Release Bundle: `flutter build appbundle --release`
4. Upload to Google Play Console (Internal Testing).
5. Pass QA → Promote to Production.

### 6.3 Monetization Workflow
- **Ads:** Banners are shown at the bottom of major list screens (Promises, Finances, People).
- **Premium:** User purchases "Pactora Plus" → `isPremiumProvider` updates → Ads are hidden and locked features (Custom Themes) are enabled.

---

## SECTION 7 — API & DATA MODELS

### Promise Model
```dart
@collection
class Promise {
  Id id = Isar.autoIncrement;
  late String title;
  String? description;
  late int personId;
  late PromiseStatus status; // pending, completed, overdue, cancelled
  DateTime? dueDate;
  late bool iMadeThisPromise;
  late DateTime createdAt;
}
```
| Field | Type | Required | Description |
|---|---|---|---|
| id | Id | Yes | Auto-incrementing primary key |
| title | String | Yes | Short summary of the promise |
| personId | int | Yes | Links to a record in the Person collection |
| status | Enum | Yes | Current state of the commitment |

---

## SECTION 8 — PLAY STORE LISTING COPY

**App Name:** Pactora: Offline Promise Tracker
**Short Description:** Never forget a promise. 100% private and offline commitment & IOU tracker.

**Full Description:**
Pactora is your ultimate personal accountability partner. Designed for those who value their word, Pactora helps you track every promise, borrowed item, and informal debt in one beautiful, private, and 100% offline app.

No accounts. No cloud. No tracking. Just your commitments, exactly where they should be—on your device.

**Why use Pactora?**
Trust is built on consistency. Whether it's returning a book, paying for a split lunch, or remembering to send that email, Pactora ensures nothing slips through the cracks.

**Key Features:**
- 📋 **Promises:** Track what you promised others and what they promised you.
- 📦 **Borrow & Lend:** Never lose a charger or book again. Track items with photos and due dates.
- 💰 **Money Tracker:** Manage informal IOUs, split bills, and small loans with payment history.
- 👤 **People Directory:** See your full "trust history" with every contact.
- 🔔 **Smart Reminders:** Get local notifications before things become overdue.
- 🔒 **Privacy First:** Your data never leaves your phone. No internet required.
- 📊 **Visual Insights:** Beautiful dashboard and activity timeline.

Stop relying on messy notes or a failing memory. Start tracking with Pactora today and become the person who always keeps their word.

**Keywords:** promise tracker, borrow lend, iou tracker, money manager, commitment tracker, offline notes, privacy app, debt tracker, personal accountability, trust builder.

---

## SECTION 9 — PRIVACY POLICY

### Pactora Privacy Policy
**Last Updated:** May 14, 2026
**Contact:** sourabh3527@gmail.com

**1. Information We Collect**
- **Personal Data:** Pactora does NOT require an account. Any name, email, or phone number you enter (e.g., for contacts) is stored locally on your device.
- **Media:** Photos taken within the app are stored in your device's private app storage.
- **Usage Data:** We do not collect app usage logs.

**2. How We Use Your Information**
Your data is used solely to provide the app's functionality on your device. We do not have access to your records.

**3. Third Parties**
- **Google AdMob:** May collect device identifiers for advertising purposes if you use the free version.
- **Google Play:** Handles payment processing for Pactora Plus.

**4. Data Retention**
All data remains on your device until you delete the app or clear its storage.

---

## SECTION 10 — TERMS OF SERVICE
**1. Acceptance:** By using Pactora, you agree to these terms.
**2. Service:** Pactora is an offline tracking tool. We are not responsible for lost data due to device failure or app deletion.
**3. Conduct:** You agree not to use the app for illegal tracking.
**4. Governing Law:** Maharashtra, India.

---

## SECTION 11 — SUPPORT & FAQ
**Support Email:** sourabh3527@gmail.com
**Response Time:** 48 Hours

**FAQ:**
1. **Is my data backed up to the cloud?** No, Pactora is 100% offline. Use the manual export feature in settings to backup your data.
2. **Can I use the app on multiple devices?** Not with synchronization. You can manually move your backup file between devices.
3. **How do I delete my data?** Go to Settings > Danger Zone > Clear All Data.

---

## SECTION 12 — CHANGELOG
**Version 1.0.0 — Initial Release**
- Initial launch of the Promises, Borrow, and Money modules.
- Local notification system for due date reminders.
- Global search and Activity timeline.
- Pactora Plus one-time upgrade.

---

## SECTION 13 — DEVELOPER NOTES
**Known Issues:**
- Recursive reminders not yet implemented (scheduled for v1.1).
- Large photo attachments may impact backup file size.

**Future Roadmap:**
- **Phase 1:** Biometric App Lock & Custom Categories.
- **Phase 2:** PDF Export for Money/Borrow summaries.
- **Phase 3:** Desktop version (macOS/Windows) with local file sync.
