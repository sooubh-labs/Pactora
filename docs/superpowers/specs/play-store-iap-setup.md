# Google Play Store IAP Setup Guide for Pactora

To make the In-App Purchases (IAP) work in production, you must configure the products in your Google Play Console to match the IDs used in the app code.

## 1. Prerequisites
- A Google Play Developer Account.
- A Merchant Account linked to your Play Console (to receive payments).
- Your app's package name (`com.example.pactora`) must be registered in the console.

## 2. Define Product IDs
The app code uses the following IDs. You **MUST** create these exact IDs in the Play Console:

| Tier | Type | Code ID | Price (Suggested) |
| :--- | :--- | :--- | :--- |
| **7-Day Ad Block** | Subscription | `premium_7_days` | ₹29 |
| **30-Day Ad Block** | Subscription | `premium_30_days` | ₹99 |
| **Lifetime Access** | In-App Product | `premium_lifetime` | ₹599 |

## 3. Step-by-Step Configuration

### A. Lifetime Access (In-App Product)
1. Go to **Monetize > Products > In-app products**.
2. Click **Create product**.
3. Product ID: `premium_lifetime`.
4. Name: `Pactora Lifetime Ad-Free`.
5. Description: `One-time purchase to remove all ads and unlock unlimited promises forever.`
6. Price: Set to ₹599 (or your local equivalent).
7. Save and **Activate**.

### B. 7-Day & 30-Day (Subscriptions)
1. Go to **Monetize > Products > Subscriptions**.
2. Click **Create subscription**.
3. For each one:
   - **Product ID:** `premium_7_days` (or `premium_30_days`).
   - **Name:** `7-Day Ad Block` (or `30-Day Ad Block`).
4. Inside the subscription, click **Create base plan**:
   - **Base plan ID:** `weekly-plan` (for 7 days) or `monthly-plan` (for 30 days).
   - **Type:** Auto-renewing.
   - **Billing period:** 1 week / 1 month.
   - **Price:** ₹29 / ₹99.
5. Save and **Activate**.

## 4. Unlocking Billing in Console
Google Play often hides the IAP sections until you upload an APK/AAB that includes the `com.android.vending.BILLING` permission. 
- The `in_app_purchase` package adds this automatically.
- Generate a release build and upload it to a **Internal Testing** track to unlock all monetization features in the console.

## 5. Testing
1. Add your email to **Setup > License testing** in the Play Console.
2. Use the **Internal Testing** track to download the app.
3. You can now "purchase" products without spending real money.
