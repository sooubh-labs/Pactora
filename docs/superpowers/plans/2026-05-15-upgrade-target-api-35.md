# Upgrade Target API Level to 35 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the Android target SDK level to 35 to comply with Google Play Store requirements.

**Architecture:** Update Gradle configuration files to set `targetSdk` and `compileSdk` to 35 (or maintain 36 for compile if beneficial). Ensure consistency across project and app-level Gradle files.

**Tech Stack:** Flutter, Gradle (KTS), Android SDK.

---

### Task 1: Update App-level Gradle Configuration

**Files:**
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Update targetSdk to 35**

```kotlin
android {
    // ...
    compileSdk = 35 // Align with target or keep 36 if preferred, but 35 is requested
    // ...
    defaultConfig {
        // ...
        targetSdk = 35
        // ...
    }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add android/app/build.gradle.kts
git commit -m "chore(android): upgrade targetSdk and compileSdk to 35"
```

### Task 2: Update Project-level Gradle Configuration

**Files:**
- Modify: `android/build.gradle.kts`

- [ ] **Step 1: Update compileSdkVersion in subprojects block**

```kotlin
subprojects {
    // ...
    afterEvaluate {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        android?.apply {
            compileSdkVersion(35)
        }
        // ...
    }
}
```

- [ ] **Step 2: Commit changes**

```bash
git add android/build.gradle.kts
git commit -m "chore(android): update subprojects compileSdkVersion to 35"
```

### Task 3: Validate and Build

- [ ] **Step 1: Clean and fetch dependencies**

Run: `flutter clean && flutter pub get`

- [ ] **Step 2: Analyze the project**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 3: Build release app bundle**

Run: `flutter build appbundle --release`
Expected: Successful generation of AAB in `build/app/outputs/bundle/release/app-release.aab`.

- [ ] **Step 4: Verify target SDK in the built AAB (Optional but recommended)**

Run: `aapt2 dump badging build/app/outputs/bundle/release/app-release.aab | grep targetSdkVersion` (if aapt2 is available)
Expected: `targetSdkVersion:'35'`
