# Interactive Onboarding Design

## Objective
Replace the long carousel of text pages with a concise, interactive setup flow.

## Design
The new onboarding consists of two main steps:

### Step 1: Quick Setup
- Replaces the multi-page carousel.
- Displays the App Logo and a Welcome message.
- Immediately asks for essential personalization: **Name** and **Preferred Currency**.
- A "Continue" button moves to the next step.

### Step 2: Interactive First Promise
- Acts as a guided tutorial by having the user create their first record.
- **UI Elements:**
  - Toggle between "They owe me" and "I owe them".
  - Text input for "Who?" (Person's name).
  - Text input for "What?" (Amount or Item).
- **Actions:**
  - "Save & Go to Dashboard": Saves the profile, saves the first record to the database, and completes onboarding.
  - "Skip for now": Saves the profile/currency preferences, completes onboarding, and goes to the dashboard without creating a record.

## Architecture & Integration
- **`OnboardingScreen`** (`lib/features/dashboard/presentation/onboarding_screen.dart`):
  - Refactored to manage the two steps using a simple `PageView` or state-based UI.
  - Removes the 5-page static data carousel (`_pages`).
  - Implements the new forms.
- **Data Saving:**
  - Step 1: Temporarily stores Name and Currency in the state.
  - Step 2: If the user saves, it uses the existing providers to persist the user preferences and the new promise record before navigating to the next screen.

## Testing
- Ensure skipping step 2 still successfully saves user preferences.
- Ensure saving step 2 creates the promise correctly in the database.
