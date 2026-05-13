# Pactora Monetization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Google AdMob banner ads and a one-time "Remove Ads" In-App Purchase with localized pricing.

**Architecture:** Use a central `AdService` for SDK lifecycle, `IapService` for store interactions, and extend `UserPreferences` with a reactive `PremiumProvider` to control ad visibility app-wide.

**Tech Stack:** Flutter, Riverpod, Google Mobile Ads, In-App Purchase, SharedPreferences.

---

### Task 1: Project Setup & Dependencies

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add dependencies to pubspec.yaml**
```yaml
dependencies:
  google_mobile_ads: ^5.1.0
  in_app_purchase: ^3.2.0
```
Run: `flutter pub get`

- [ ] **Step 2: Add AdMob App ID to AndroidManifest.xml**
Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/> <!-- Test ID -->
```

- [ ] **Step 3: Commit setup**
```bash
git add pubspec.yaml android/app/src/main/AndroidManifest.xml
git commit -m "chore: add ad mobility and iap dependencies"
```

### Task 2: Core Ad Service

**Files:**
- Create: `lib/core/ads/ad_constants.dart`
- Create: `lib/core/ads/ad_service.dart`

- [ ] **Step 1: Create AdConstants**
```dart
class AdConstants {
  // Test IDs for Android
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
}
```

- [ ] **Step 2: Create AdService**
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}
```

- [ ] **Step 3: Initialize in main.dart**
Modify `lib/main.dart` to call `AdService.instance.initialize()` before `runApp`.

- [ ] **Step 4: Commit AdService**
```bash
git add lib/core/ads/ lib/main.dart
git commit -m "feat: initialize AdMob SDK"
```

### Task 3: Premium State Management

**Files:**
- Modify: `lib/core/providers/user_preferences_provider.dart`

- [ ] **Step 1: Add isPremium to UserPreferences model**
Update `UserPreferences` class and `copyWith`.

- [ ] **Step 2: Add persistence for isPremium**
Update `UserPreferencesNotifier` to load/save `is_premium` key from `SharedPreferences`.

- [ ] **Step 3: Create premiumProvider helper**
```dart
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(userPreferencesProvider).isPremium;
});
```

- [ ] **Step 4: Commit preferences change**
```bash
git commit -am "feat: add premium status to user preferences"
```

### Task 4: Reusable Banner Widget

**Files:**
- Create: `lib/core/ads/banner_ad_widget.dart`

- [ ] **Step 1: Implement BannerAdWidget**
Create a `StatefulWidget` that:
- Watches `isPremiumProvider`.
- Returns `SizedBox.shrink()` if premium.
- Loads a `BannerAd` on `initState`.
- Disposes it on `dispose`.
- Displays the ad using `AdWidget`.

- [ ] **Step 2: Commit widget**
```bash
git add lib/core/ads/banner_ad_widget.dart
git commit -m "feat: create reusable BannerAdWidget"
```

### Task 5: Ad Injection in List Screens

**Files:**
- Modify: `lib/features/promises/presentation/promises_screen.dart`
- Modify: `lib/features/dashboard/presentation/timeline_screen.dart`

- [ ] **Step 1: Inject ads every 5th item**
Update `ListView.separated` logic:
```dart
separatorBuilder: (context, index) {
  if ((index + 1) % 5 == 0) {
    return const BannerAdWidget();
  }
  return const Divider();
}
```

- [ ] **Step 2: Commit injections**
```bash
git commit -am "feat: inject ads into promise and timeline feeds"
```

### Task 6: IAP Service & Upgrade UI

**Files:**
- Create: `lib/core/iap/iap_service.dart`
- Create: `lib/features/settings/presentation/premium_screen.dart`

- [ ] **Step 1: Implement IapService**
Handle `InAppPurchase.instance.purchaseStream`, product loading, and purchase completion.

- [ ] **Step 2: Build PremiumScreen**
Display localized price from `ProductDetails` and benefits.

- [ ] **Step 3: Add entry point in Settings**
Add "Go Premium" tile to `lib/features/settings/presentation/settings_screen.dart`.

- [ ] **Step 4: Final commit**
```bash
git add lib/core/iap/ lib/features/settings/presentation/
git commit -m "feat: implement IAP removal of ads"
```
