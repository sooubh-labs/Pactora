# Horizontal Calendar Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Optimize `HorizontalCalendar` performance, use standard utilities for date comparison, and strengthen its tests.

**Architecture:** 
- Convert `activeDates` to a `Set<int>` (representing normalized milliseconds since epoch or similar) for O(1) activity check.
- Replace manual date comparisons with `isSameDay` from `table_calendar`.
- Enhance widget tests to verify full date selection.

**Tech Stack:** Flutter, `table_calendar`, `intl`

---

### Task 1: Performance and Utils Fix in HorizontalCalendar

**Files:**
- Modify: `lib/shared/widgets/horizontal_calendar.dart`

- [x] **Step 1: Update imports and state**
Add `import 'package:table_calendar/table_calendar.dart';`.
Update `_HorizontalCalendarState` to pre-calculate a `Set` of active dates for efficient lookup.

- [x] **Step 2: Implement efficient activity check and use `isSameDay`**
Modify `_hasActivity` and build method to use `isSameDay` and the new `Set`.

```dart
// In _HorizontalCalendarState
late Set<DateTime> _normalizedActiveDates;

@override
void didUpdateWidget(HorizontalCalendar oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (widget.activeDates != oldWidget.activeDates) {
    _updateNormalizedDates();
  }
}

void _updateNormalizedDates() {
  _normalizedActiveDates = widget.activeDates
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet();
}

bool _hasActivity(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return _normalizedActiveDates.contains(normalized);
}

// In build method
final isSelected = isSameDay(date, _selectedDate);
```

### Task 2: Improve Tests

**Files:**
- Modify: `test/shared/widgets/horizontal_calendar_test.dart`

- [x] **Step 1: Enhance assertions**
Update the test to verify `year` and `month` in addition to `day`.

```dart
expect(selected?.year, today.year);
expect(selected?.month, today.month);
expect(selected?.day, today.day);
```

- [x] **Step 2: Run tests to verify**
Run: `flutter test test/shared/widgets/horizontal_calendar_test.dart`
Expected: PASS
