# 07. Monetization Strategy — Pactora

## Hybrid Model
Pactora utilizes a non-intrusive hybrid monetization strategy designed to keep the app free for basic users while offering a "Pro" experience for power users.

## 1. Google Mobile Ads (Free Tier)
- **Ad Type:** Adaptive Banners only.
- **Placement:** Bottom of the screen in the following views:
  - Promises List
  - Finances (Money/Borrow) List
  - People List
- **User Experience:** Banners are placed using a `SafeArea` and `SizedBox` to ensure they don't overlap with FABs or interactive UI elements.

## 2. Pactora Plus (Premium Upgrade)
A one-time In-App Purchase (IAP) that removes all ads and unlocks exclusive features.

**Price Point:** ₹199 / $2.99 (Market-dependent).

**Unlocked Features:**
- **Ad-Free Experience:** Complete removal of all banner ad units.
- **Custom Themes:** Access to 5+ accent color schemes (Blue, Purple, Green, Orange, Monochrome).
- **Advanced Analytics:** Detailed charts showing promise completion rates and money trends.
- **Nag Mode:** Option to repeat overdue notifications every 24 hours.
- **PDF Export:** Generate summary reports for money and borrow records.

## 3. Implementation Details
- **Ad Service:** `core/ads/ad_service.dart` handles initialization and loading.
- **IAP Service:** `core/iap/iap_service.dart` manages the connection to Google Play and stores the "Premium" status in a secure local flag.
- **UI Logic:** The `isPremiumProvider` is watched by the `BannerAdWidget` to determine visibility.
