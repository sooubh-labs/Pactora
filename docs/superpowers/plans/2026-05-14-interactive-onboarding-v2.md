# Interactive Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current static onboarding carousel with a 2-step interactive flow (Profile Setup & First Promise creation).

**Architecture:** We will replace the 5-page carousel in `OnboardingScreen` with a `PageView` containing exactly two pages: one for setting the user's name and currency, and another for optionally creating their first promise. We will use the existing `PersonRepository` and `PromiseRepository` to save the interactive data.

**Tech Stack:** Flutter, Riverpod, Isar

---

### Task 1: Refactor OnboardingScreen Layout

**Files:**
- Modify: `lib/features/dashboard/presentation/onboarding_screen.dart`

- [ ] **Step 1: Replace the carousel structure with the new two-step structure.**
Replace the entire `_pages` and `_OnboardingPage` logic with two simple custom widgets: `_WelcomeSetupPage` and `_FirstPromisePage`.

```dart
// At the top of lib/features/dashboard/presentation/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_preferences_provider.dart';
import '../../../core/services/data_seed_service.dart';
import '../../people/data/person_repository.dart';
import '../../people/domain/person_model.dart';
import '../../promises/data/promise_repository.dart';
import '../../promises/domain/promise_enums.dart';
import '../../promises/domain/promise_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Step 1 State
  final _nameController = TextEditingController();
  CurrencyOption _selectedCurrency = currencyOptions.first;

  // Step 2 State
  bool _theyOweMe = true;
  final _whoController = TextEditingController();
  final _whatController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _whoController.dispose();
    _whatController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  Future<void> _completeOnboarding({bool skipPromise = false}) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name on the previous step')),
      );
      return;
    }

    if (!skipPromise && _whoController.text.trim().isNotEmpty && _whatController.text.trim().isNotEmpty) {
      // Save Person and Promise
      final personRepo = PersonRepository();
      final promiseRepo = PromiseRepository();
      
      final person = Person()..name = _whoController.text.trim();
      final personId = await personRepo.savePerson(person);
      
      final promise = Promise()
        ..title = _whatController.text.trim()
        ..personId = personId
        ..type = _theyOweMe ? PromiseType.theyPromised : PromiseType.iPromised
        ..category = PromiseCategory.other
        ..priority = Priority.medium
        ..iMadeThisPromise = !_theyOweMe;
        
      await promiseRepo.savePromise(promise);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    await ref.read(userPreferencesProvider.notifier).updateProfile(name: _nameController.text.trim());
    await ref.read(userPreferencesProvider.notifier).updateCurrency(_selectedCurrency.symbol, _selectedCurrency.code);

    if (mounted) context.go('/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPagePhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/app-logo.png', width: 120, height: 120),
          const Gap(24),
          const Text('Welcome to Pactora!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Let\'s get your profile set up so you can start tracking promises.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const Gap(48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'YOUR NAME', hintText: 'e.g. Alex'),
          ),
          const Gap(24),
          DropdownButtonFormField<CurrencyOption>(
            value: _selectedCurrency,
            decoration: const InputDecoration(labelText: 'PREFERRED CURRENCY'),
            items: currencyOptions.map((opt) => DropdownMenuItem(
              value: opt,
              child: Text('${opt.name} (${opt.symbol})'),
            )).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCurrency = val);
            },
          ),
          const Gap(48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Add Your First Record', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Let\'s track something someone owes you or you owe them.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const Gap(48),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _theyOweMe = true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: _theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('They owe me', style: TextStyle(color: _theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _theyOweMe = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: !_theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('I owe them', style: TextStyle(color: !_theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
          const Gap(32),
          TextField(
            controller: _whoController,
            decoration: const InputDecoration(hintText: 'Who? (e.g. John)'),
          ),
          const Gap(16),
          TextField(
            controller: _whatController,
            decoration: const InputDecoration(hintText: 'What? (e.g. \$20 for lunch or a Book)'),
          ),
          const Gap(48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeOnboarding(skipPromise: false),
              child: const Text('Save & Go to Dashboard'),
            ),
          ),
          const Gap(16),
          TextButton(
            onPressed: () => _completeOnboarding(skipPromise: true),
            child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Check formatting and clean up unused code**
Remove `OnboardingPageData`, `_OnboardingPage`, and `_PersonalizationPage` from the bottom of the file since they are no longer used.

- [ ] **Step 3: Commit**

```bash
git add lib/features/dashboard/presentation/onboarding_screen.dart
git commit -m "feat: implement interactive 2-step onboarding flow"
```

---
