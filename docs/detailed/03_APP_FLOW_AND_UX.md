# 03. App Flow & UX Design — Pactora

## Screen Journey Architecture

### Phase 1: The Gateway
1. **Splash Screen (`/splash`):** Database initialization. Logo fade-in.
2. **Onboarding (`/onboarding`):** 5-page walkthrough of value (Privacy, Promises, Items, Money).
3. **Permission Setup (`/permissions`):** Non-blocking request for Notifications and Media.

### Phase 2: The Command Center
4. **Home Dashboard (`/dashboard`):** 
   - **Summary Chips:** Live count of Pending, Overdue, Borrowed, and Owed.
   - **Due Today:** High-priority list of items requiring action now.
   - **Recent Activity:** Timeline snippets.
5. **Quick Add Sheet:** Triggered by FAB. Fast entry points for all 3 modules.

### Phase 3: Domain Lists & Filtering
6. **Promises List (`/promises`):** Filter by status (All, Pending, Overdue, Done).
7. **Borrow List (`/borrow`):** Filter by Lent vs. Borrowed.
8. **Money List (`/money`):** Summary of total owed vs. lent, filtered by status.
9. **People List (`/people`):** Searchable directory of contacts.

### Phase 4: Detailed Views & Forms
10. **Add/Edit Screens:** Feature-specific forms with validation.
11. **Detail Screens:** Deep dive into specific records with action bars (Complete, Snooze, Share).
12. **Person Profile:** 3-tab view (Promises, Items, Money) for that specific individual.

### Phase 5: Search & Discovery
13. **Global Search (`/search`):** Real-time results grouped by type.
14. **Activity Timeline (`/timeline`):** Full scrollable history of app usage.
15. **Calendar View (`/calendar`):** Monthly view with event dots.

### Phase 6: Management & Settings
16. **Settings (`/settings`):** Primary configuration hub.
17. **Backup/Restore:** File-based data management screens.
18. **Pactora Plus:** Upsell screen for premium features.
19. **About & FAQ:** Support and legal information.

## UX Principles
- **Speed to Entry:** Minimize taps to record a commitment.
- **Visual Feedback:** Use color-coding (Red for Overdue, Green for Done, Blue for Active).
- **Privacy Transparency:** Constant reminders that data is local.
- **Non-Invasive Ads:** Banners only, no interstitials or rewarded videos that break flow.
