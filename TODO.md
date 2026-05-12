# Pactora Development Plan - UI Polish & Image Integration

## Phase 1: Visual Refinements
- [ ] **Fix Promises Card:** Ensure left color strip covers full expanded height.
- [ ] **Dashboard Spacing:** Re-audit and tighten gap between stat boxes and activity.
- [ ] **Calendar Refinement:** 
    - Reduce `HorizontalCalendar` height.
    - Improve rounding and alignment of date pills.
- [ ] **Consistency Audit:** 
    - Verify all major cards use consistent `borderRadius` (32 or 24).
    - Ensure all page headers and paddings are uniform.

## Phase 2: Native Configuration & Services
- [ ] **Android Permissions:** Add gallery/camera permissions to `AndroidManifest.xml`.
- [ ] **iOS Permissions:** Add usage descriptions to `Info.plist`.
- [ ] **Image Service:** Create `lib/core/services/image_service.dart` to handle picking and permission requests.

## Phase 3: Image Upload Integration
- [ ] **Profile Screen:** Allow users to pick/change their avatar from gallery.
- [ ] **Add Promise Screen:** Add "Attach Proof" button for image upload.
- [ ] **Add Money Screen:** Add "Attach Receipt/Proof" functionality.
- [ ] **Add Item Screen:** Add "Attach Photo" functionality for item condition.

## Phase 4: Verification
- [ ] Run `flutter analyze` to ensure code quality.
- [ ] Verify scrolling smoothness on real-world list sizes.
