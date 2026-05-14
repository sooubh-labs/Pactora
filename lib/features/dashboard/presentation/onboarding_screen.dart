import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_preferences_provider.dart';
import '../../../core/services/data_seed_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final _nameController = TextEditingController();
  CurrencyOption _selectedCurrency = currencyOptions.first;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.handshake,
      title: 'Welcome to Pactora',
      body: 'Track every promise, borrow, and IOU — all in one place.',
    ),
    OnboardingPageData(
      icon: Icons.check_circle_outline,
      title: 'Track Your Promises',
      body: 'Never lose track of "I\'ll send it tonight" or "Call me after class."',
    ),
    OnboardingPageData(
      icon: Icons.swap_horiz,
      title: 'Borrow & Lend',
      body: 'Remember who has your charger or book, and when they\'re returning it.',
    ),
    OnboardingPageData(
      icon: Icons.payments_outlined,
      title: 'Money Tracker',
      body: 'Track small teas to larger loans. Know exactly who owes what.',
    ),
    OnboardingPageData(
      icon: Icons.security_outlined,
      title: '100% Private & Offline',
      body: 'Everything stays on your device. No account. No cloud. No tracking.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length + 1,
                itemBuilder: (context, index) {
                  if (index < _pages.length) {
                    return _OnboardingPage(
                      data: _pages[index],
                      isFirstPage: index == 0,
                    );
                  } else {
                    return _PersonalizationPage(
                      nameController: _nameController,
                      selectedCurrency: _selectedCurrency,
                      onCurrencyChanged: (currency) {
                        setState(() => _selectedCurrency = currency!);
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length + 1,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == _pages.length ? 'Get Started' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() async {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      
      await ref.read(userPreferencesProvider.notifier).updateProfile(name: _nameController.text.trim());
      await ref.read(userPreferencesProvider.notifier).updateCurrency(_selectedCurrency.symbol, _selectedCurrency.code);

      // Seed initial data for a better first experience
      await DataSeedService.seed();

      if (mounted) context.go('/permissions');
    }
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String body;

  OnboardingPageData({required this.icon, required this.title, required this.body});
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final bool isFirstPage;

  const _OnboardingPage({required this.data, this.isFirstPage = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFirstPage)
            Image.asset('assets/images/app-logo.png', width: 200, height: 200)
          else
            Icon(data.icon, size: 100, color: Theme.of(context).colorScheme.primary),
          const Gap(48),
          Text(
            data.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Text(
            data.body,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PersonalizationPage extends StatelessWidget {
  final TextEditingController nameController;
  final CurrencyOption selectedCurrency;
  final ValueChanged<CurrencyOption?> onCurrencyChanged;

  const _PersonalizationPage({
    required this.nameController,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Almost there!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            'Let\'s personalize your experience.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(48),
          const Text(
            'What should we call you?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const Gap(32),
          const Text(
            'Preferred Currency',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          DropdownButtonFormField<CurrencyOption>(
            value: selectedCurrency,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.payments_outlined),
            ),
            items: currencyOptions.map((opt) {
              return DropdownMenuItem(
                value: opt,
                child: Text('${opt.symbol} ${opt.code} (${opt.name})'),
              );
            }).toList(),
            onChanged: onCurrencyChanged,
          ),
        ],
      ),
    );
  }
}
