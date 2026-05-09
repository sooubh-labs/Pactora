import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'dashboard_provider.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/quick_add_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pactora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/timeline'),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => context.push('/archive'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryGrid(summary, context),
              const Gap(24),
              const Text('Due Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Gap(12),
              const _DueTodayList(),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryGrid(DashboardSummary summary, BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Pending',
          count: summary.pendingPromises.toString(),
          color: AppColors.pending,
          icon: Icons.handshake_outlined,
          onTap: () => context.go('/promises'),
        ),
        _StatCard(
          label: 'Overdue',
          count: summary.overduePromises.toString(),
          color: AppColors.overdue,
          icon: Icons.warning_amber_rounded,
          onTap: () => context.go('/promises'),
        ),
        _StatCard(
          label: 'Borrowed',
          count: summary.activeBorrows.toString(),
          color: AppColors.borrow,
          icon: Icons.swap_horiz,
          onTap: () => context.go('/borrow'),
        ),
        _StatCard(
          label: 'Owed',
          count: '₹${summary.moneyOwedToMe.toStringAsFixed(0)}',
          color: AppColors.money,
          icon: Icons.currency_rupee,
          onTap: () => context.go('/money'),
        ),
      ],
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const QuickAddSheet(),
    );
  }
}

class _DueTodayList extends ConsumerWidget {
  const _DueTodayList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueTodayAsync = ref.watch(dueTodayPromisesProvider);

    return dueTodayAsync.when(
      data: (promises) {
        if (promises.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Nothing due today 🎉')),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: promises.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final promise = promises[index];
            return Card(
              child: ListTile(
                title: Text(promise.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/promises/${promise.id}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  Text(
                    count,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              const Spacer(),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
