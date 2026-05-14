# Interactive Guide and Data Seeding Design

## Objective
Enhance the first-time user experience by providing sample data and an interactive visual tour of the app's core functions.

## Components

### 1. Data Seeding Service (`lib/core/services/data_seed_service.dart`)
- **Purpose:** Inject dummy data into the Isar database for new users.
- **Trigger:** Called at the end of the `OnboardingScreen` flow.
- **Data to be seeded:**
    - **People:** 
        - Sarah (Person)
        - John (Person)
    - **Items:**
        - **Promise:** "Call Sarah about the trip" (Linked to Sarah, Category: Task)
        - **Borrow:** "Lent 'Clean Code' to John" (Linked to John, Category: Borrow)
        - **Money:** "Owe $20 to Sarah for Dinner" (Linked to Sarah, Category: Money)

### 2. Guide Service (`lib/core/services/guide_service.dart`)
- **Purpose:** Track whether the interactive guide has been shown to the user.
- **Storage:** Uses `SharedPreferences` with the key `guide_shown`.

### 3. Feature Guide Widget (`lib/shared/widgets/feature_guide.dart`)
- **Purpose:** A reusable overlay component that highlights specific parts of the UI.
- **UI Mechanism:** 
    - A `Stack` or `OverlayEntry` with a `CustomPainter` to draw a "hole" (clipping) around a target area.
    - A text bubble explaining the highlighted feature.
    - "Next" and "Skip" buttons.
- **Tour Steps (on Dashboard):**
    1. **Stats Grid:** Highlights the `_buildSummaryGrid`.
    2. **Activity List:** Highlights the `Recent Activity` section.
    3. **Navigation Bar:** Highlights the bottom navigation bar.

### 4. Integration
- **`OnboardingScreen`:** Calls `DataSeedService.seed()` before navigating to the next screen.
- **`DashboardScreen`:** Checks `GuideService.shouldShowGuide()`. If true, displays the `FeatureGuide` overlay.

## Data Flow
1. User completes onboarding → `DataSeedService` writes to Isar → `onboarding_complete` set to `true`.
2. User lands on `DashboardScreen` → `GuideService` checks `guide_shown` → `FeatureGuide` overlay triggers.
3. User completes/skips tour → `guide_shown` set to `true`.

## Testing Strategy
- **Unit Test:** Verify `DataSeedService` correctly inserts the expected number of items.
- **Manual Test:** 
    - Clear app data, run onboarding, verify 3 items appear on Dashboard.
    - Verify the interactive guide appears and correctly highlights the intended sections.
    - Verify the guide does not reappear after completion.
