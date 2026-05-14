import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'stats_provider.dart';
import '../../promises/domain/promise_enums.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/providers/user_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(pactoraStatsProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics & Reports')),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(context, stats, prefs.currencySymbol),
              const Gap(24),
              Text('Promise Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(16),
              _buildCategoryPieChart(context, stats),
              const Gap(24),
              Text('Completion Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(16),
              _buildStatusPieChart(context, stats),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: Theme.of(context).textTheme.bodyMedium)),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, PactoraStats stats, String currencySymbol) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _StatCard(label: 'Total Promises', value: stats.totalPromises.toString(), color: theme.colorScheme.primary),
        _StatCard(label: 'Completion Rate', value: '${stats.completionRate.toStringAsFixed(1)}%', color: theme.colorScheme.secondary),
        _StatCard(label: 'Owed to Me', value: '$currencySymbol${stats.totalMoneyOwedToMe.toStringAsFixed(0)}', color: AppColors.success),
        _StatCard(label: 'I Owe', value: '$currencySymbol${stats.totalMoneyIOwe.toStringAsFixed(0)}', color: theme.colorScheme.error),
      ],
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, PactoraStats stats) {
    if (stats.categoryDistribution.isEmpty) return Center(child: Text('No data', style: Theme.of(context).textTheme.bodyMedium));

    final data = stats.categoryDistribution.entries.map((e) {
      final config = CategoryConstants.categories[e.key]!;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: config.color,
        radius: 50,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(height: 200, child: PieChart(PieChartData(sections: data))),
        const Gap(16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stats.categoryDistribution.keys.map((cat) {
            final config = CategoryConstants.categories[cat]!;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: config.color),
                const Gap(4),
                Text(
                  config.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusPieChart(BuildContext context, PactoraStats stats) {
    if (stats.statusDistribution.isEmpty) return Center(child: Text('No data', style: Theme.of(context).textTheme.bodyMedium));

    final data = stats.statusDistribution.entries.map((e) {
      Color color = AppColors.textTertiary;
      switch (e.key) {
        case PromiseStatus.completed: color = AppColors.success; break;
        case PromiseStatus.pending: color = AppColors.warning; break;
        case PromiseStatus.overdue: color = AppColors.error; break;
        default: break;
      }
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: color,
        radius: 50,
        titleStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();

    return SizedBox(height: 200, child: PieChart(PieChartData(sections: data)));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const Gap(4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
