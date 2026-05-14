import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pactora/core/iap/iap_service.dart';
import 'package:pactora/core/theme/app_colors.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  List<ProductDetails>? _products;
  bool _isLoading = true;
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _listenToErrors();
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  void _listenToErrors() {
    _errorSubscription = ref.read(iapServiceProvider).errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }

  Future<void> _loadProducts() async {
    final products = await ref.read(iapServiceProvider).loadProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pactora Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.stars_rounded,
              size: 80,
              color: isDark ? theme.colorScheme.secondary : AppColors.primary,
            ),
            const Gap(16),
            Text(
              'Upgrade to Premium',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
            ),
            const Gap(8),
            Text(
              'Remove all ads and support the development of Pactora.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
            ),
            const Gap(32),
            _buildBenefitsGrid(context),
            const Gap(40),
            Text(
              'Choose Your Plan',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildPricingOptions(context),
            const Gap(32),
            TextButton(
              onPressed: () => ref.read(iapServiceProvider).restorePurchases(),
              child: Text(
                'Already purchased? Restore Purchase',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? theme.colorScheme.secondary : AppColors.primary,
                ),
              ),
            ),
            const Gap(48),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid(BuildContext context) {
    return Column(
      children: [
        _buildBenefitItem(
          context,
          icon: Icons.block_rounded,
          title: 'Ad-Free Experience',
          description: 'No more banners or rewarded ad interruptions.',
        ),
        const Gap(16),
        _buildBenefitItem(
          context,
          icon: Icons.all_inclusive_rounded,
          title: 'Unlimited Promises',
          description: 'Remove the 10-promise batch limit forever.',
        ),
        const Gap(16),
        _buildBenefitItem(
          context,
          icon: Icons.favorite_rounded,
          title: 'Support Private Dev',
          description: 'Help us keep Pactora 100% offline and private.',
        ),
      ],
    );
  }

  Widget _buildPricingOptions(BuildContext context) {
    // If no real products loaded (e.g. emulator), show mock ones for UI preview
    if (_products == null || _products!.isEmpty) {
      return Column(
        children: [
          _buildMockCard(context, 'Weekly Ad-Block', '₹29', '7 Days'),
          const Gap(16),
          _buildMockCard(context, 'Monthly Ad-Block', '₹99', '30 Days'),
          const Gap(16),
          _buildMockCard(context, 'Lifetime Access', '₹599', 'Forever', isPopular: true),
        ],
      );
    }

    // Sort products: 7 days, 30 days, Lifetime
    final sortedProducts = List<ProductDetails>.from(_products!);
    sortedProducts.sort((a, b) {
      if (a.id.contains('7_days')) return -1;
      if (b.id.contains('7_days')) return 1;
      if (a.id.contains('30_days')) return -1;
      if (b.id.contains('30_days')) return 1;
      return 0;
    });

    return Column(
      children: sortedProducts.map((product) {
        final isLifetime = product.id.contains('lifetime');
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPurchaseCard(context, product, isPopular: isLifetime),
        );
      }).toList(),
    );
  }

  Widget _buildMockCard(BuildContext context, String title, String price, String duration, {bool isPopular = false}) {
    return _buildBaseCard(
      context,
      title: title,
      price: price,
      duration: duration,
      isPopular: isPopular,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase simulation: Connect to Google Play for real purchase.')),
        );
      },
    );
  }

  Widget _buildPurchaseCard(BuildContext context, ProductDetails product, {bool isPopular = false}) {
    String duration = 'Forever';
    if (product.id.contains('7_days')) duration = '7 Days';
    if (product.id.contains('30_days')) duration = '30 Days';

    return _buildBaseCard(
      context,
      title: product.title.split('(').first.trim(),
      price: product.price,
      duration: duration,
      isPopular: isPopular,
      onTap: () => ref.read(iapServiceProvider).buyPremium(product),
    );
  }

  Widget _buildBaseCard(
    BuildContext context, {
    required String title,
    required String price,
    required String duration,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? theme.colorScheme.secondary : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? primaryColor : (isDark ? AppColors.borderDark : Colors.black.withOpacity(0.05)),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isDark 
          ? [] 
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isPopular ? primaryColor.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPopular ? Icons.auto_awesome_rounded : Icons.calendar_today_rounded,
                      color: isPopular ? primaryColor : (isDark ? AppColors.textTertiaryDark : Colors.grey[600]),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          duration,
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: isPopular ? primaryColor : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        'one-time',
                        style: TextStyle(
                          fontSize: 10, 
                          color: isDark ? AppColors.textTertiaryDark : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? theme.colorScheme.secondary : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
              ),
              const Gap(4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
