import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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
  
  // Step 1 State
  final _nameController = TextEditingController();
  CurrencyOption _selectedCurrency = currencyOptions.first;
  bool _acceptedTerms = false;

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
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Privacy Policy')),
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

    await DataSeedService.seed();

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
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _WelcomeSetupPage(
                    nameController: _nameController,
                    selectedCurrency: _selectedCurrency,
                    acceptedTerms: _acceptedTerms,
                    onCurrencyChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                    onTermsChanged: (val) {
                      setState(() => _acceptedTerms = val ?? false);
                    },
                    onNext: _nextPage,
                  ),
                  _FirstPromisePage(
                    theyOweMe: _theyOweMe,
                    onOweChanged: (val) => setState(() => _theyOweMe = val),
                    whoController: _whoController,
                    whatController: _whatController,
                    onComplete: _completeOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSetupPage extends StatelessWidget {
  final TextEditingController nameController;
  final CurrencyOption selectedCurrency;
  final bool acceptedTerms;
  final ValueChanged<CurrencyOption?> onCurrencyChanged;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onNext;

  const _WelcomeSetupPage({
    required this.nameController,
    required this.selectedCurrency,
    required this.acceptedTerms,
    required this.onCurrencyChanged,
    required this.onTermsChanged,
    required this.onNext,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(40),
          Image.asset('assets/images/app-logo.png', width: 140, height: 140),
          const Gap(24),
          const Text('Welcome to Pactora!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(8),
          const Text('Let\'s get your profile set up so you can start tracking promises.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const Gap(48),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'YOUR NAME', hintText: 'e.g. Alex'),
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(24),
          DropdownButtonFormField<CurrencyOption>(
            value: selectedCurrency,
            decoration: const InputDecoration(labelText: 'PREFERRED CURRENCY'),
            items: currencyOptions.map((opt) => DropdownMenuItem(
              value: opt,
              child: Text('${opt.name} (${opt.symbol})'),
            )).toList(),
            onChanged: onCurrencyChanged,
          ),
          const Gap(32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: acceptedTerms,
                  onChanged: onTermsChanged,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I agree to the terms and privacy policy',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _launchUrl('https://sooubh.github.io/pactora/terms.html'),
                          child: Text(
                            'Terms',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(' & ', style: TextStyle(fontSize: 12)),
                        GestureDetector(
                          onTap: () => _launchUrl('https://sooubh.github.io/pactora/privacy.html'),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstPromisePage extends StatelessWidget {
  final bool theyOweMe;
  final ValueChanged<bool> onOweChanged;
  final TextEditingController whoController;
  final TextEditingController whatController;
  final void Function({bool skipPromise}) onComplete;

  const _FirstPromisePage({
    required this.theyOweMe,
    required this.onOweChanged,
    required this.whoController,
    required this.whatController,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => onOweChanged(true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('They owe me', style: TextStyle(color: theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: GestureDetector(
                  onTap: () => onOweChanged(false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: !theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('I owe them', style: TextStyle(color: !theyOweMe ? Theme.of(context).colorScheme.primary : Colors.grey, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
          const Gap(32),
          TextField(
            controller: whoController,
            decoration: const InputDecoration(hintText: 'Who? (e.g. John)'),
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(16),
          TextField(
            controller: whatController,
            decoration: const InputDecoration(hintText: 'What? (e.g. \$20 for lunch or a Book)'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const Gap(48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onComplete(skipPromise: false),
              child: const Text('Save & Go to Dashboard'),
            ),
          ),
          const Gap(16),
          TextButton(
            onPressed: () => onComplete(skipPromise: true),
            child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
