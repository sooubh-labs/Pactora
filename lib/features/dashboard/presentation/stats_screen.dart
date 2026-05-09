import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'stats_provider.dart';
import '../../promises/domain/promise_enums.dart';
import '../../../core/constants/category_constants.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(pactoraStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics & Reports')),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(stats),
              const Gap(24),
              const Text('Promise Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              _buildCategoryPieChart(stats),
              const Gap(24),
              const Text('Completion Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(16),
              _buildStatusPieChart(stats),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildOverviewCards(PactoraStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _StatCard(label: 'Total Promises', value: stats.totalPromises.toString(), color: Colors.blue),
        _StatCard(label: 'Completion Rate', value: '${stats.completionRate.toStringAsFixed(1)}%', color: Colors.green),
        _StatCard(label: 'Owed to Me', value: '₹${stats.totalMoneyOwedToMe.toStringAsFixed(0)}', color: Colors.teal),
        _StatCard(label: 'I Owe', value: '₹${stats.totalMoneyIOwe.toStringAsFixed(0)}', color: Colors.red),
      ],
    );
  }

  Widget _buildCategoryPieChart(PactoraStats stats) {
    if (stats.categoryDistribution.isEmpty) return const Center(child: Text('No data'));

    final data = stats.categoryDistribution.entries.map((e) {
      final config = CategoryConstants.categories[e.key]!;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: config.color,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                Text(config.label, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusPieChart(PactoraStats stats) {
    if (stats.statusDistribution.isEmpty) return const Center(child: Text('No data'));

    final data = stats.statusDistribution.entries.map((e) {
      Color color = Colors.grey;
      switch (e.key) {
        case PromiseStatus.completed: color = Colors.green; break;
        case PromiseStatus.pending: color = Colors.orange; break;
        case PromiseStatus.overdue: color = Colors.red; break;
        default: break;
      }
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const Gap(4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
