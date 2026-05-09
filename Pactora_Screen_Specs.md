# Pactora — Complete Screen Specifications
> Never forget a promise. | 100% Offline Flutter App

**Total Screens: 34**
**MVP Screens: 17 | Production V1 Screens: 17 additional**

---

## Navigation Map

```
Bottom Nav:     Home | Promises | Borrow | Money | People
Top-level:      Search | Settings
From Home FAB:  Quick Add Sheet
From Settings:  Backup, Restore, Theme, App Lock, About, Storage, Notif Templates
From Promises:  Add Promise → Promise Detail
From Borrow:    Add Borrow Item → Borrow Item Detail
From Money:     Add Money Record → Money Record Detail
From People:    Add Person → Person Profile
```

---

# MVP SCREENS (1–17)

---

## Screen 1 — Splash Screen

**Route:** `/splash`
**Purpose:** App boot + initialization gate

### UI
- Full-screen dark background (`#1C1C3A`)
- Pactora logo centered (animated fade-in + subtle scale)
- Tagline: *"Never forget a promise."* below logo
- Thin linear progress bar at bottom (optional)
- No back button, no nav bar

### Logic
```
On mount:
1. IsarService.init()
2. NotificationService.init()
3. Load theme preference from SharedPreferences
4. Check if onboarding completed (flag in SharedPreferences)
   → false → navigate to Onboarding
   → true  → navigate to Home Dashboard
```

### Transition
- Duration: ~1.5–2s minimum (even if init is fast, show logo briefly)
- Fade-out transition to next screen

---

## Screen 2 — Onboarding

**Route:** `/onboarding`
**Purpose:** Explain core value, build trust, get user started

### UI Structure
- `PageView` with 5 pages
- Dot indicators at bottom
- Skip button (top-right) on pages 1–4
- "Get Started" CTA button on page 5
- Smooth page-slide animations

### Pages

| # | Illustration | Headline | Body |
|---|---|---|---|
| 1 | Handshake / wave icon | Welcome to Pactora | Track every promise, borrow, and IOU — all in one place. |
| 2 | Checkmark / promise icon | Track Your Promises | Never lose track of "I'll send it tonight" or "Call me after class." |
| 3 | Box / swap icon | Borrow & Lend | Remember who has your charger, book, or calculator — and when they're returning it. |
| 4 | Rupee / wallet icon | Money, Made Simple | Track ₹50 teas to ₹1000 loans. Know exactly who owes what. |
| 5 | Lock / shield icon | 100% Private & Offline | Everything stays on your device. No account. No cloud. No tracking. |

### Actions
- `Skip` → marks onboarding complete → navigate `/permissions`
- `Get Started` (page 5) → navigate `/permissions`
- Swipe left/right between pages

---

## Screen 3 — Permission Setup

**Route:** `/permissions`
**Purpose:** Request necessary device permissions upfront

### UI
- Simple centered card layout
- Each permission as a row: icon + title + description + grant button
- "Continue" button at bottom (enabled even if permissions denied — app works without them)

### Permissions

| Permission | Icon | Why Needed |
|---|---|---|
| Notifications | Bell | Reminders for due promises and overdue items |
| Storage / Media | Image | Attach photos to borrow items and receipts |

### Logic
```
Grant Notification → flutter_local_notifications requestPermission()
Grant Storage      → image_picker handles this natively on tap
Continue           → mark permissions_shown = true → navigate /home
```

### Notes
- Never block app usage on permission denial
- Show friendly explanation, not system dialog immediately
- Tap "Grant" → then trigger system dialog

---

## Screen 4 — Home Dashboard

**Route:** `/home`
**Purpose:** Command center, daily overview at a glance

### AppBar
- Title: "Pactora" or greeting "Good morning, Sourabh 👋"
- Actions: Search icon → `/search` | Settings icon → `/settings`

### FAB
- Extended FAB: `+ Add` 
- On tap → opens `QuickAddSheet` (bottom sheet)

### Body — Scrollable Column

#### Section 1: Summary Row (4 stat chips)
```
[ 📋 Pending: N ]  [ ⚠️ Overdue: N ]  [ 📦 Borrowed: N ]  [ 💰 Owed: ₹N ]
```
- Horizontally scrollable `Row` of `StatChip` widgets
- Tap each chip → navigates to relevant tab with filter applied

#### Section 2: Overdue Banner (conditional)
```
⚠️  3 things are overdue — tap to review
```
- Shows only if overdue count > 0
- Highlighted card with `AppColors.overdue` accent
- Tap → navigates to `/promises?filter=overdue`

#### Section 3: Today's Commitments
- Section header: "Due Today" + count badge
- `ListView` of `PromiseCard` widgets (due today)
- Empty state: "Nothing due today 🎉"
- Max 5 shown → "See all" link

#### Section 4: Overdue Borrowed Items
- Section header: "Overdue Items"
- List of `BorrowItemCard` where status = overdue
- Hidden if none

#### Section 5: Money Due
- Section header: "Money Due"
- List of `MoneyCard` where status = pending + due soon
- Hidden if none

#### Section 6: Recent Activity
- Section header: "Recent"
- Last 5 actions across all modules (chronological)
- Each row: icon + description + relative time
  - e.g. "Rahul returned charger · 2h ago"

### Navigation
- Bottom nav bar visible
- Selected: Home

---

## Screen 5 — All Promises

**Route:** `/promises`
**Purpose:** Full promise management

### AppBar
- Title: "Promises"
- Actions: Search icon, Filter icon

### Tabs
```
[ All ]  [ Pending ]  [ Overdue ]  [ Completed ]
```
- `TabBar` + `TabBarView`
- Each tab shows filtered `ListView`

### Filter / Sort Bottom Sheet (on filter icon tap)
```
Sort by:   Due Date ● | Created Date | Priority
Filter:    All ● | Pending | Overdue | Completed | Delayed | Cancelled
Category:  All | Task | Money | Meeting | Callback | Errand | Document | Personal
Person:    All | [list of people]
```

### Promise Card (each list item)
```
┌─────────────────────────────────────────┐
│ [Category icon]  Title              [Status chip]  │
│                  👤 Person name                    │
│                  📅 Due: Mon, Jan 13 · 2 days left │
│                  [Priority dot]                    │
└─────────────────────────────────────────┘
```
- Swipe right → Mark Complete (green)
- Swipe left → Delete (red)
- Tap → `/promise/:id`

### Empty State
- Illustration + "No promises yet"
- "Add your first promise" button

### FAB
- `+` → `/add-promise`

---

## Screen 6 — Add Promise

**Route:** `/add-promise`
**Purpose:** Create a new promise record

### AppBar
- Title: "New Promise"
- Back arrow
- "Save" text button (top-right)

### Form Fields

| Field | Widget | Required |
|---|---|---|
| Title | `TextFormField` | ✅ |
| Description | `TextFormField` multiline | ❌ |
| Person | `PersonPickerField` (dropdown + add new) | ✅ |
| Category | `CategoryChipSelector` (horizontal scroll) | ✅ |
| Priority | `SegmentedButton`: Low / Medium / High | ✅ |
| Due Date | `DatePickerField` | ❌ |
| Due Time | `TimePickerField` | ❌ |
| Reminder | `ReminderPickerField` | ❌ |
| Who promised? | `Toggle`: I promised / They promised | ✅ |
| Notes | `TextFormField` multiline | ❌ |

### Category Chips (horizontal scroll)
```
📋 Task  📁 File  📞 Callback  📅 Meeting  💰 Payment  🏃 Errand  👤 Personal  ⋯ Other
```

### Reminder Options
```
None | 15 min before | 1 hour before | 1 day before | On due date | Custom
```

### Validation
- Title required
- Person required (or create inline)
- If due time set → due date required
- If reminder set → due date required

### On Save
```
1. Validate form
2. Insert Promise into Isar
3. Schedule notification (if reminder set)
4. Navigate back to /promises
5. Show SnackBar: "Promise added ✓"
```

---

## Screen 7 — Promise Detail

**Route:** `/promise/:id`
**Purpose:** View full promise, take actions

### AppBar
- Title: promise title (truncated)
- Actions: Edit icon → `/edit-promise/:id` | More menu (3-dot)

### Body

#### Status Banner
```
[ ⏳ PENDING ]  or  [ ✅ COMPLETED ]  or  [ 🔴 OVERDUE ]
```
Color-coded full-width banner at top

#### Info Section
```
📋 Title:        Return charger
📝 Description:  Borrowed after class
👤 Person:       Rahul  [→ person profile chip]
🏷 Category:     Personal
⭐ Priority:      High
📅 Due Date:     Monday, Jan 13, 2025
🕐 Due Time:     6:00 PM
🔔 Reminder:     1 hour before
📌 Notes:        Red OnePlus charger, kept in bag
📆 Created:      Jan 10, 2025
```

#### Action Buttons Row
```
[✅ Mark Complete]  [💤 Snooze]  [📤 Send Reminder]
```

#### More Menu (3-dot)
- Edit
- Change Status (sub-menu)
- Delete (with confirmation dialog)

### Send Reminder Action
- Generates message: *"Hey Rahul, friendly reminder about the charger 🙂"*
- Opens share sheet (share_plus)
- No API, fully manual

### Snooze Options
```
Snooze for: 1 hour | Tomorrow | 3 days | 1 week
```

---

## Screen 8 — Borrow & Lend List

**Route:** `/borrow`
**Purpose:** Track all physical borrowed/lent items

### AppBar
- Title: "Borrow & Lend"
- Actions: Filter icon

### Tabs
```
[ All ]  [ Active ]  [ Overdue ]  [ Returned ]
```

### Filter Bottom Sheet
```
Type:    All ● | I Lent | I Borrowed
Status:  All | Active | Overdue | Returned | Lost
Person:  All | [person list]
```

### Borrow Item Card
```
┌──────────────────────────────────────────────┐
│ [📷 Item photo or icon]   Charger            │
│                           👤 Rahul           │
│                           ↗ I Lent           │
│                           📅 Due: Jan 15     │
│                           [OVERDUE chip]     │
└──────────────────────────────────────────────┘
```
- Swipe right → Mark Returned
- Swipe left → Delete
- Tap → `/borrow/:id`

### Summary Bar (top of list)
```
📦 Lent: 3 items  |  📥 Borrowed: 2 items
```

### Empty State
- Icon + "Nothing borrowed or lent"
- "Track an item" button

### FAB
- `+` → `/add-item`

---

## Screen 9 — Add Borrow Item

**Route:** `/add-item`
**Purpose:** Record a borrow or lend

### AppBar
- Title: "New Item"
- Back arrow + "Save" button

### Form Fields

| Field | Widget | Required |
|---|---|---|
| Item Name | `TextFormField` | ✅ |
| Type | `ToggleButtons`: I Lent / I Borrowed | ✅ |
| Person | `PersonPickerField` | ✅ |
| Due/Return Date | `DatePickerField` | ❌ |
| Estimated Value (₹) | `TextFormField` numeric | ❌ |
| Condition | `SegmentedButton`: New / Good / Fair / Damaged | ✅ |
| Notes | `TextFormField` multiline | ❌ |
| Photo | `ImagePickerField` (tap to add, shows thumbnail) | ❌ |

### Photo Picker
- Tap camera icon → image_picker (camera or gallery)
- Shows 80×80 thumbnail after selection
- Stores path in app documents directory

### On Save
```
1. Copy image to app directory (if selected)
2. Insert BorrowItem into Isar
3. Schedule reminder (if due date set)
4. Navigate back → show SnackBar "Item tracked ✓"
```

---

## Screen 10 — Borrow Item Detail

**Route:** `/borrow/:id`
**Purpose:** Full item view + lifecycle management

### AppBar
- Title: item name
- Actions: Edit | 3-dot menu

### Body

#### Item Image
- Full-width image card (if photo exists)
- Placeholder icon (no photo)

#### Info Section
```
📦 Item:       Charger (Red OnePlus)
↗ Type:        I Lent
👤 Person:     Rahul
📅 Lent on:    Jan 10, 2025
📅 Due back:   Jan 15, 2025  [OVERDUE]
💰 Value:      ₹800
📋 Condition:  Good
📌 Notes:      Keep it safe
```

#### Status Badge
- Color-coded: Active (blue) | Overdue (red) | Returned (green) | Lost (grey)

#### Action Buttons
```
[✅ Mark Returned]  [📤 Send Reminder]  [❌ Mark Lost]
```

#### More Menu
- Edit
- Delete (confirm dialog)

---

## Screen 11 — Money Tracker

**Route:** `/money`
**Purpose:** Overview of all informal money commitments

### AppBar
- Title: "Money"
- Actions: Filter icon

### Summary Cards Row
```
┌──────────────────┐  ┌──────────────────┐
│  💰 Owed to Me   │  │  💸 I Owe        │
│  ₹1,250          │  │  ₹300            │
└──────────────────┘  └──────────────────┘
```

### Tabs
```
[ All ]  [ Owed to Me ]  [ I Owe ]  [ Overdue ]  [ Settled ]
```

### Money Card
```
┌──────────────────────────────────────────────┐
│ 👤 Rahul                    ₹500  →  THEY OWE │
│ Cab split from last week                      │
│ 📅 Due: Jan 20              [PENDING chip]    │
└──────────────────────────────────────────────┘
```
- Swipe right → Mark Settled
- Swipe left → Delete
- Tap → `/money/:id`

### FAB
- `+` → `/add-money`

---

## Screen 12 — Add Money Record

**Route:** `/add-money`
**Purpose:** Record a new money commitment

### AppBar
- Title: "New Money Record"
- Back + Save

### Form Fields

| Field | Widget | Required |
|---|---|---|
| Amount | `TextFormField` numeric, large font | ✅ |
| Currency | `DropdownField`: ₹ INR / $ USD / € EUR | ✅ |
| Type | `ToggleButtons`: I Owe / They Owe Me | ✅ |
| Person | `PersonPickerField` | ✅ |
| Due Date | `DatePickerField` | ❌ |
| Description | `TextFormField` (e.g., "Cab split", "Tea") | ❌ |
| Partial Paid | `TextFormField` numeric | ❌ |
| Notes | `TextFormField` multiline | ❌ |

### Amount Input UX
- Large centered number input (like payment apps)
- Currency symbol prefix
- Numeric keyboard on focus

### On Save
```
1. Insert MoneyRecord into Isar
2. Schedule reminder (if due date set)
3. Navigate back → SnackBar "Record added ✓"
```

---

## Screen 13 — Money Record Detail

**Route:** `/money/:id`
**Purpose:** Full transaction view + payment tracking

### AppBar
- Title: person name + amount
- Actions: Edit | 3-dot menu

### Body

#### Header Card
```
₹500
They owe me
👤 Rahul · Cab split
```

#### Info Section
```
💰 Amount:      ₹500
✅ Paid so far: ₹200
⏳ Remaining:   ₹300
📅 Due:         Jan 20, 2025
📋 Status:      Partial
📌 Notes:       Office cab last Tuesday
```

#### Payment Progress Bar
```
[████████░░░░░░░░]  ₹200 / ₹500
```

#### Action Buttons
```
[+ Add Payment]  [✅ Settle Full]  [📤 Send Reminder]
```

#### Add Payment Bottom Sheet
- Amount field
- Date field
- Note (optional)
- Save → updates `paidAmount`, recalculates remaining

#### More Menu
- Edit
- Delete (confirm)

---

## Screen 14 — People List

**Route:** `/people`
**Purpose:** Directory of all tracked people

### AppBar
- Title: "People"
- Actions: Search icon, Add icon → `/add-person`

### Search Bar (inline, always visible)
- Filters list in real-time using Isar query

### Person Card
```
┌──────────────────────────────────────────────┐
│ [Avatar]  Rahul                              │
│           📋 4 promises  📦 2 items  💰 ₹300 │
└──────────────────────────────────────────────┘
```
- Avatar: initials-based colored circle (no photo needed)
- Tap → `/person/:id`
- Long press → quick actions (add promise, delete)

### Empty State
- "No people yet"
- "Add someone" button

### FAB
- `+` → `/add-person`

---

## Screen 15 — Person Profile

**Route:** `/person/:id`
**Purpose:** Full relationship history per person

### AppBar
- Person name as title
- Actions: Edit | 3-dot menu

### Header
```
[Avatar - large 64px]
Rahul
📞 98XXXXXX10  (if added)
Member since Jan 2025
```

#### Trust Score (optional, toggleable in settings)
```
⭐ Reliability: 82%   (8 of 10 promises kept)
```

### Summary Row
```
[ 📋 Promises: 10 ]  [ ✅ Done: 8 ]  [ ⚠️ Overdue: 2 ]
[ 📦 Items: 3 ]      [ 💰 Pending: ₹500 ]
```

### Tabs
```
[ Promises ]  [ Borrowed ]  [ Money ]
```

Each tab shows filtered list of that person's records.

### Quick Action Buttons
```
[+ Promise]  [+ Item]  [+ Money]  [📤 Reminder]
```

### More Menu
- Edit person
- Delete person (with warning: "This will not delete linked records")

---

## Screen 16 — Global Search

**Route:** `/search`
**Purpose:** Find anything across all modules

### AppBar
- Autofocused `SearchBar` (full-width)
- Cancel button → pops screen

### Recent Searches
- Shows last 5 search terms (stored in SharedPreferences)
- Clear all button

### Results (shown after typing 2+ characters)
- Grouped by type:

```
PROMISES (3)
├── Return charger to Rahul
├── Send PPT to Priya
└── Pay ₹300 for lunch

PEOPLE (1)
└── Rahul Sharma

BORROWED ITEMS (1)
└── Calculator — from Arun

MONEY (2)
├── ₹300 — Priya owes me
└── ₹50 — I owe Karan
```

### Filter Chips (horizontal scroll, above results)
```
[ All ● ]  [ Promises ]  [ People ]  [ Items ]  [ Money ]
```

### Empty State
- "No results for 'xyz'"

### Isar Queries Used
```dart
// Promises: filter title + description + personName
// BorrowItems: filter itemName + personName
// MoneyRecords: filter description + personName
// Persons: filter name + phone
```

---

## Screen 17 — Settings

**Route:** `/settings`
**Purpose:** App configuration, backup, privacy

### AppBar
- Title: "Settings"
- Back arrow

### Sections

#### Notifications
- Default reminder timing: `[1 hour before ▼]`
- Nag mode: `[Toggle]` (repeat daily for overdue items)
- Quiet hours: `[Set time range]`

#### Data & Backup
- Export backup → `/backup-export`
- Import backup → `/backup-restore`
- Storage info → `/storage-manager`

#### Appearance
- Theme → `/theme-settings`
- (Production V1 feature, show "Coming Soon" badge in MVP)

#### Security
- App lock → `/app-lock-setup`
- (Production V1 feature, show "Coming Soon" badge in MVP)

#### About
- App version: `v1.0.0`
- Changelog
- Privacy policy (local HTML or text)
- Contact / Feedback → email intent

#### Danger Zone
- Clear all data (confirmation: type "DELETE")

---

---

# PRODUCTION V1 SCREENS (18–34)

---

## Screen 18 — Calendar View

**Route:** `/calendar`
**Purpose:** Monthly overview of all commitments

### UI
- `TableCalendar` package or custom `GridView`
- Month navigation: `<` January 2025 `>`

### Date Cell Indicators
- Colored dots on dates with commitments:
  - 🔵 Promise due
  - 🟠 Borrow return due
  - 🟢 Money due
  - 🔴 Overdue (takes priority)

### Selected Day Panel (bottom sheet or expandable)
Shows all commitments for selected day:
```
Monday, Jan 13
├── 📋 Return charger (Rahul)
├── 💰 ₹300 due (Priya)
└── 📦 Calculator return expected
```

### Navigation
- Accessible from Settings or via swipe on Dashboard
- Or add to bottom nav in v1

---

## Screen 19 — Timeline Activity

**Route:** `/timeline`
**Purpose:** Chronological history of all actions

### AppBar
- Title: "Activity"
- Filter icon

### Timeline List
Each item:
```
[Icon]  Action description
        Relative time · Person (if applicable)
```

Examples:
```
✅  Promise completed: Return charger
    2 hours ago · Rahul

⚠️  Item overdue: Calculator
    1 day ago · Arun

💰  Payment added: ₹200 partial
    3 days ago · Priya

📋  Promise created: Send PPT
    Jan 10, 2025
```

### Filters
```
All | Promises | Items | Money | Reminders
```

### Empty State
- "No activity yet"

---

## Screen 20 — Quick Add

**Route:** bottom sheet (no dedicated route)
**Purpose:** Fast capture of any commitment type

### Trigger
- FAB from any bottom nav tab

### UI
- `DraggableScrollableSheet`
- 4 template tiles in a 2×2 grid:

```
┌──────────────┐  ┌──────────────┐
│  📋 Promise  │  │  📦 Borrow   │
└──────────────┘  └──────────────┘
┌──────────────┐  ┌──────────────┐
│  💰 Money    │  │  📅 Meeting  │
└──────────────┘  └──────────────┘
```

- Each tile: icon + label + color
- Tap → navigate to respective Add screen with `type` prefilled

### Optional: Inline Quick Promise
- Title field + Person field at top of sheet
- "Quick save" saves with minimal fields (no date/reminder)
- "More options" → full Add screen

---

## Screen 21 — Reminder Center

**Route:** `/reminders`
**Purpose:** Central inbox for all notifications and due alerts

### AppBar
- Title: "Reminders"
- Actions: Mark all read | Settings icon

### Tabs
```
[ Upcoming ]  [ Missed ]  [ Overdue ]
```

### Reminder Card
```
┌─────────────────────────────────────────┐
│ 🔔  Return charger to Rahul             │
│     Due in 2 hours                      │
│     [Snooze]  [Mark Done]               │
└─────────────────────────────────────────┘
```

### Snooze Bottom Sheet
```
Snooze for: [1 hour]  [3 hours]  [Tomorrow]  [1 week]
```

### Empty States (per tab)
- "No upcoming reminders"
- "No missed reminders 🎉"

---

## Screen 22 — Analytics Dashboard

**Route:** `/analytics`
**Purpose:** Personal accountability insights

### AppBar
- Title: "Insights"
- Period selector: Week | Month | All time

### Cards/Charts

#### Completion Rate
```
Promise Completion Rate
[████████░░]  78%
This month: 14/18 kept
```
Donut chart

#### Overdue Trends
- Line chart: overdue count per week (last 4 weeks)

#### Top People
```
Most commitments with:
1. Rahul   —  12 promises
2. Priya   —  8 promises
3. Arun    —  5 promises
```

#### Borrow Stats
```
📦 Total lent: 8 items  |  7 returned (88%)
📥 Total borrowed: 5 items  |  5 returned (100%)
```

#### Money Summary
```
💰 Total tracked: ₹4,500
   Recovered: ₹3,200 (71%)
   Still pending: ₹1,300
```

#### Category Breakdown
- Bar chart: promises per category

---

## Screen 23 — Attachment Viewer

**Route:** `/attachment/:path`
**Purpose:** View locally stored files/images

### Supports
- Images (JPEG, PNG) — full-screen `InteractiveViewer` with pinch-to-zoom
- Text notes — scrollable text view

### AppBar
- File name as title
- Actions: Share (share_plus) | Delete

### No internet, no cloud — all local paths from Isar `photoPath` fields

---

## Screen 24 — Backup Export

**Route:** `/backup-export`
**Purpose:** Save all data locally or share as file

### AppBar
- Title: "Export Backup"

### Content
- Last backup info: "Last backed up: Jan 10, 2025" or "Never"
- Backup summary:
  ```
  📋 Promises: 18
  📦 Items: 7
  💰 Money records: 12
  👤 People: 6
  ```
- Format selector: JSON (free) | Encrypted JSON (Premium)

### Actions
```
[💾 Save to Device]    [📤 Share File]
```

### Process
```
1. BackupService.exportToJson()
2. Write to temp file: commitly_backup_TIMESTAMP.json
3. share_plus or FileSaver
4. Update last backup timestamp
```

---

## Screen 25 — Backup Restore

**Route:** `/backup-restore`
**Purpose:** Restore data from a backup file

### AppBar
- Title: "Restore Backup"

### Warning Card
```
⚠️  Restoring will merge with or replace existing data.
    This cannot be undone.
```

### File Picker Button
```
[📂 Choose Backup File]
```
- `file_picker` → `.json` files only

### After File Selected — Preview Card
```
Backup from: Jan 10, 2025
Version: 1

📋 Promises: 18
📦 Items: 7
💰 Records: 12
👤 People: 6

[✅ Restore Now]  [❌ Cancel]
```

### Restore Options
```
◉ Merge with existing data
○ Replace all data (clear first)
```

### Process
```
1. Parse JSON
2. Validate version
3. Insert all records (merge or clear+insert)
4. Show SnackBar: "Restore complete ✓"
5. Navigate back to Home
```

---

## Screen 26 — Theme Settings

**Route:** `/theme-settings`
**Purpose:** Appearance customization

### AppBar
- Title: "Appearance"

### Sections

#### Mode
```
◉ Dark (default)
○ Light
○ System
```

#### Accent Colors (Premium)
- Color palette grid: 8 options
- Default: `#4E75F6` (Pactora Blue)
- Locked behind Premium badge in free tier

#### Font Size
```
[A-]  Normal  [A+]
Slider: Small → Large
```

#### Preview Card
- Shows a live mock of a Promise card with selected settings

---

## Screen 27 — App Lock Setup

**Route:** `/app-lock-setup`
**Purpose:** Add a security layer to the app

### AppBar
- Title: "App Lock"

### Toggle
```
App Lock  [Toggle OFF → ON]
```

### Lock Type (shown when enabled)
```
◉ Biometric (Face / Fingerprint)
○ PIN Code
```

### Biometric Setup
- Uses `local_auth` package
- "Test biometric" button before saving

### PIN Setup
- 4-digit PIN entry (custom numpad)
- Confirm PIN screen
- Store encrypted in `flutter_secure_storage`

### Recovery
- "Forgot PIN? Clear app data" warning

---

## Screen 28 — Lock Screen

**Route:** `/lock`
**Purpose:** Secure entry gate

### UI
- Full-screen dark background
- Pactora logo + "Unlock Pactora"
- Biometric prompt auto-triggered on screen load
- Fallback: PIN numpad (4 dots + number grid)
- "Use PIN instead" if biometric fails

### Logic
```
On mount → local_auth.authenticate()
Success → navigate to /home
Fail → show PIN fallback
3 wrong PINs → 30s lockout
```

---

## Screen 29 — Notification Templates

**Route:** `/notif-templates`
**Purpose:** Customize auto-generated reminder messages

### AppBar
- Title: "Reminder Messages"

### Template List (one per category)
```
💰 Money:     "Hey {name}, friendly reminder about the {amount} 😊"
📦 Borrow:    "Hey {name}, when can I expect {item} back? 🙏"
📋 Promise:   "Hey {name}, just checking on '{title}' 😊"
📅 Meeting:   "Hey {name}, are we still on for {title}? 🙂"
📞 Callback:  "Hey {name}, give me a call when you're free 😊"
```

### Edit Template
- Tap any template → text editor
- Variable chips: `{name}` `{item}` `{amount}` `{title}` `{date}`
- Tap chip → inserts at cursor
- "Preview" button → shows sample output
- Reset to default button

---

## Screen 30 — Category Manager

**Route:** `/categories`
**Purpose:** Customize commitment categories

### Default Categories (non-deletable)
```
📋 Task | 📁 File | 📞 Callback | 📅 Meeting
💰 Payment | 🏃 Errand | 👤 Personal | ⋯ Other
```

### Custom Categories
- `+` button → name + emoji picker + color picker
- Swipe to delete (custom only)
- Drag to reorder

### Used In
- Add Promise category picker
- Analytics category breakdown

---

## Screen 31 — Storage Manager

**Route:** `/storage`
**Purpose:** App storage transparency + cleanup tools

### AppBar
- Title: "Storage"

### Breakdown
```
Total app size:     12.4 MB

📊 Database:        2.1 MB
🖼  Photos:          9.8 MB
🔊 Voice notes:     0 MB
💾 Backups:         0.5 MB
🗂  Cache:           0.0 MB
```

Progress bar per category.

### Actions
```
[🗑 Clear Cache]       [🗑 Delete All Photos]
[🗑 Delete Old Backups]
```

Each action → confirmation dialog with exact size to be freed

### Photo List
- "View all stored photos" expandable section
- Thumbnail grid
- Individual delete option

---

## Screen 32 — About & Feedback

**Route:** `/about`
**Purpose:** App info, legal, support

### Sections

#### App Info
```
Pactora
Version 1.2.0 (Build 12)
Made with ❤️ by [Your Name]
```

#### What's New (Changelog)
- Expandable list of recent version notes

#### Legal
- Privacy Policy (local text)
- Terms of Use (local text)
- Open Source Licenses (`showLicensePage()`)

#### Support
- Contact: opens email app (mailto intent)
- Rate on Play Store: opens store URL
- Share app: share_plus deeplink

---

## Screen 33 — Pactora Plus

**Route:** `/plus`
**Purpose:** Premium upgrade screen

### AppBar
- Title: "Pactora Plus"

### Hero Section
```
⭐  Pactora Plus
    Unlock the full experience — one time, forever.
    ₹199  (or $2.99)
```

### Feature Comparison Table
```
Feature                    Free    Plus
─────────────────────────────────────
Promises                   ∞       ∞
People                     ∞       ∞
Borrow tracking            ∞       ∞
Money tracking             ∞       ∞
Photo attachments          3       ∞
Reminders per item         1       ∞ + nag mode
Analytics                  ✗       ✓
PDF export                 ✗       ✓
Encrypted backup           ✗       ✓
Custom themes              1       5+
Category manager           ✗       ✓
App lock                   ✗       ✓
```

### CTA Button
```
[⭐  Get Pactora Plus — ₹199]
```
- `in_app_purchase` → one-time product

### Restore Purchase
- "Already purchased? Restore" text link

---

## Screen 34 — Contact Import

**Route:** `/import-contacts`
**Purpose:** Import people from phone contacts (optional, privacy-first)

### AppBar
- Title: "Import Contacts"

### Permission Gate
- "Pactora needs Contacts permission to show your contacts."
- [Grant Access] button → system permission dialog

### Contact List (after permission)
- Searchable list of phone contacts
- Each row: initials avatar + name + phone
- Checkbox selection (multi-select)

### Import Button
```
[Import 3 selected contacts]
```

### Logic
```
1. contacts_service package
2. Read name + phone only (no syncing, no cloud)
3. Create Person records in Isar
4. Navigate to /people
5. SnackBar: "3 people added ✓"
```

### Privacy Note (always visible)
```
🔒 Contacts are only read locally and never leave your device.
```

---

# Summary Table

| # | Screen | Route | Module | MVP |
|---|---|---|---|---|
| 1 | Splash | `/splash` | Core | ✅ |
| 2 | Onboarding | `/onboarding` | Core | ✅ |
| 3 | Permission Setup | `/permissions` | Core | ✅ |
| 4 | Home Dashboard | `/home` | Core | ✅ |
| 5 | All Promises | `/promises` | Promises | ✅ |
| 6 | Add Promise | `/add-promise` | Promises | ✅ |
| 7 | Promise Detail | `/promise/:id` | Promises | ✅ |
| 8 | Borrow & Lend List | `/borrow` | Borrow | ✅ |
| 9 | Add Borrow Item | `/add-item` | Borrow | ✅ |
| 10 | Borrow Item Detail | `/borrow/:id` | Borrow | ✅ |
| 11 | Money Tracker | `/money` | Money | ✅ |
| 12 | Add Money Record | `/add-money` | Money | ✅ |
| 13 | Money Record Detail | `/money/:id` | Money | ✅ |
| 14 | People List | `/people` | People | ✅ |
| 15 | Person Profile | `/person/:id` | People | ✅ |
| 16 | Global Search | `/search` | Core | ✅ |
| 17 | Settings | `/settings` | Core | ✅ |
| 18 | Calendar View | `/calendar` | V1 | — |
| 19 | Timeline Activity | `/timeline` | V1 | — |
| 20 | Quick Add Sheet | bottom sheet | V1 | — |
| 21 | Reminder Center | `/reminders` | V1 | — |
| 22 | Analytics Dashboard | `/analytics` | V1 | — |
| 23 | Attachment Viewer | `/attachment/:path` | V1 | — |
| 24 | Backup Export | `/backup-export` | V1 | — |
| 25 | Backup Restore | `/backup-restore` | V1 | — |
| 26 | Theme Settings | `/theme-settings` | V1 | — |
| 27 | App Lock Setup | `/app-lock-setup` | V1 | — |
| 28 | Lock Screen | `/lock` | V1 | — |
| 29 | Notification Templates | `/notif-templates` | V1 | — |
| 30 | Category Manager | `/categories` | V1 | — |
| 31 | Storage Manager | `/storage` | V1 | — |
| 32 | About & Feedback | `/about` | V1 | — |
| 33 | Pactora Plus | `/plus` | V1 | — |
| 34 | Contact Import | `/import-contacts` | V1 | — |

---

*Pactora — Never forget a promise.*
