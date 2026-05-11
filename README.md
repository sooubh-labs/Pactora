# Pactora

**Never forget a promise.** | 100% Offline Commitment Tracker.

Pactora is a privacy-focused Flutter application designed to help you track promises, borrowed items, and informal money records without any cloud synchronization or account requirements. Everything stays on your device.

## 🚀 Features

- **Promises:** Track commitments made by you or to you.
- **Borrow & Lend:** Keep record of physical items like books, chargers, or tools.
- **Money Tracker:** Informal IOUs and small loan tracking with payment history.
- **People Directory:** Manage contacts and see your transaction history with each.
- **Visual Insights:** Dashboard summary, Calendar view, and Activity timeline.
- **Privacy First:** No accounts, no internet required, 100% offline database (Isar).
- **Notifications:** Local reminders for due dates and overdue items.

## 🛠 Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Riverpod](https://riverpod.dev/) (with Code Generation)
- **Database:** [Isar](https://isar.dev/) (High-performance NoSQL)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Local Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Styling:** Material 3 with custom brand themes.

## 📦 Getting Started

### Prerequisites
- Flutter SDK: `>=3.19.0`
- Dart SDK: `>=3.0.0 <4.0.0`

### Installation
1. Clone the repository.
2. Run `flutter pub get`.
3. Generate required code (Isar & Riverpod):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 📂 Project Structure

- `lib/app/`: Core app configuration and routing.
- `lib/core/`: Shared services (Isar, Notifications), themes, and constants.
- `lib/features/`: Feature-based modules (Promises, Borrow, Money, People, Dashboard, Search, Settings).
- `lib/shared/`: Reusable widgets used across multiple features.

## 📄 Documentation

Detailed specifications and plans can be found in the `docs/` directory:
- [Navigation & Screen Specs](docs/superpowers/specs/pactora-screen-specs.md)
- [Design Refactor](docs/superpowers/specs/2026-05-11-navigation-refactor-design.md)

## 🛡 License

Private Project - All rights reserved.
