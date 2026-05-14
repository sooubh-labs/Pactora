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

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pactora Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 80,
              color: AppColors.primary,
            ),
            const Gap(16),
            Text(
              'Upgrade to Premium',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),
            Text(
              'Get the most out of Pactora with these exclusive features.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const Gap(32),
            _buildBenefitItem(
              context,
              icon: Icons.block,
              title: 'Remove Advertisements',
              description: 'Enjoy a clean, ad-free experience while managing your promises.',
            ),
            const Gap(16),
            _buildBenefitItem(
              context,
              icon: Icons.favorite,
              title: 'Support Development',
              description: 'Help us keep Pactora free of trackers and maintain its offline-first privacy.',
            ),
            const Gap(16),
            _buildBenefitItem(
              context,
              icon: Icons.cloud_done,
              title: 'Future Features',
              description: 'Get early access to upcoming features like advanced backup and insights.',
            ),
            const Gap(48),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_products == null || _products!.isEmpty)
              const Center(
                child: Text(
                  'No products available for purchase at this time.',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._products!.map((product) => _buildPurchaseCard(context, product)),
            const Gap(24),
            TextButton(
              onPressed: () => ref.read(iapServiceProvider).restorePurchases(),
              child: const Text('Already purchased? Restore Purchase'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseCard(BuildContext context, ProductDetails product) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              product.title.split('(').first.trim(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(8),
            Text(
              product.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),
            Text(
              product.price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const Gap(16),
            ElevatedButton(
              onPressed: () => ref.read(iapServiceProvider).buyPremium(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
