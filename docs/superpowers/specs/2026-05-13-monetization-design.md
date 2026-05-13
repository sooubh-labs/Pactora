# Design Spec: Pactora Monetization (AdMob + IAP)

## Overview
Implement a sustainable monetization strategy for Pactora using Google AdMob for banner ads and In-App Purchases (IAP) for a one-time "Premium" upgrade to remove ads.

## Goals
- Integrate banner ads into list-heavy screens without degrading user experience.
- Provide a clear value proposition for the Premium upgrade.
- Ensure ads are hidden immediately and permanently for Premium users.
- Support localized pricing based on the user's currency.

## Architecture

### 1. Ad Service (`lib/core/ads/`)
- **`AdService`**: Singleton class to initialize the Mobile Ads SDK and manage `BannerAd` instances.
- **`AdConstants`**: Storage for Ad Unit IDs (Testing placeholders initially).
- **`BannerAdWidget`**: A reusable wrapper widget that handles ad loading, disposing, and conditional visibility based on premium status.

### 2. IAP Service (`lib/core/iap/`)
- **`IapService`**: Manages the connection to the Google Play Store using the `in_app_purchase` package.
- **`PremiumProvider` (Riverpod)**:
  - Tracks `isPremium` state.
  - Persists state locally (via `SharedPreferences` or `Isar`) for offline validation.
  - Handles the "Restore Purchase" logic.

### 3. Localization
- Use `ProductDetails.price` from the IAP package to display the exact price in the user's local currency as defined in their store account.
- Fallback to `userPreferencesProvider.currencySymbol` for manual formatting if store pricing is unavailable.

## User Experience

### Ad Placements
- **In-Feed**: Every 5th item in `PromisesScreen`, `TimelineScreen`, and `ArchiveScreen`.
- **Sticky Banner**: Bottom of `PromiseDetailScreen` and `PersonDetailScreen`.

### Premium Upgrade
- **CTA**: "Go Premium" button in Settings.
- **Upgrade Screen**: Dedicated screen showing benefits (No Ads, Support Developer) and the localized price.
- **Entitlement**: Once purchased, all `BannerAdWidget` instances will return `SizedBox.shrink()`.

## Implementation Plan
1. Add `google_mobile_ads` and `in_app_purchase` to `pubspec.yaml`.
2. Create core ad and IAP services.
3. Update `UserPreferences` to track `isPremium`.
4. Implement `BannerAdWidget`.
5. Refactor list screens to inject ads.
6. Build the Premium upgrade UI.

## Verification
- Verify ad test units display correctly.
- Verify "Remove Ads" flow hides all ads.
- Verify premium state persists after app restart.
- Verify localized price display.
