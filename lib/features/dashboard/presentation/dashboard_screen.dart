import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_preferences_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, prefs),
            _buildSearchBar(context),
            Expanded(
              child: summaryAsync.when(
                data: (summary) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), // Reduced vertical from 16
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryGrid(summary, context, prefs.currencySymbol),
                      const SizedBox(height: 24), // Reduced from 32/20
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/timeline'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Reduced from 16
                      _buildRecentActivity(summary.recentActivity, context),
                      const SizedBox(height: 140), // padding for floating nav
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserPreferences prefs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: prefs.profileImagePath.isNotEmpty ? FileImage(File(prefs.profileImagePath)) : null,
              child: prefs.profileImagePath.isEmpty ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 28) : null,
            ),
          ),
          Text(
            'Pactora',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 28),
              color: AppColors.primary,
              onPressed: () => context.push('/timeline'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.6), size: 24),
              const SizedBox(width: 12),
              Text(
                'Search promises, people...',
                style: TextStyle(
                  color: AppColors.textTertiary.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<ActivityItemData> activities, BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'No recent activity',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        IconData icon;
        Color color;
        Color bgColor;
        String route;

        if (activity.isCompleted) {
          color = AppColors.doneText;
          bgColor = AppColors.doneBg;
        } else {
          color = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
        }

        switch (activity.type) {
          case ActivityType.promise:
            icon = Icons.handshake_rounded;
            route = '/promises/${activity.id}';
            break;
          case ActivityType.borrow:
            icon = Icons.inventory_2_outlined;
            route = '/borrow/${activity.id}';
            if (!activity.isCompleted) {
              color = const Color(0xFFD81B60);
              bgColor = const Color(0xFFFCE4EC);
            }
            break;
          case ActivityType.money:
            icon = Icons.payments_outlined;
            route = '/money/${activity.id}';
            if (!activity.isCompleted) {
              color = AppColors.primaryLight;
              bgColor = AppColors.primaryLight.withOpacity(0.1);
            }
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _ActivityItem(
            title: activity.title,
            subtitle: activity.subtitle,
            icon: icon,
            color: color,
            bgColor: bgColor,
            onTap: () => context.push(route),
          ),
        );
      }).toList(),
    );
  }

  String _formatMoney(double amount, String symbol) {
    if (amount >= 1000000) return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  Widget _buildSummaryGrid(DashboardSummary summary, BuildContext context, String currencySymbol) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        double childAspectRatio = 1.15;
        
        if (constraints.maxWidth > 800) {
          crossAxisCount = 4;
          childAspectRatio = 1.3;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 3;
          childAspectRatio = 1.2;
        }

        return GridView.count(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _StatCard(
              label: 'Pending Promises',
              count: summary.pendingPromises.toString(),
              color: AppColors.pendingText,
              bgColor: AppColors.pendingBg,
              icon: Icons.hourglass_empty_rounded,
              onTap: () => context.go('/promises?filter=pending'),
            ),
            _StatCard(
              label: 'Overdue Items',
              count: summary.overduePromises.toString(),
              color: AppColors.overdueText,
              bgColor: AppColors.overdueBg,
              icon: Icons.warning_amber_rounded,
              onTap: () => context.go('/promises?filter=overdue'),
            ),

            _StatCard(
              label: 'Borrowed Items',
              count: summary.activeBorrows.toString(),
              color: const Color(0xFFD81B60),
              bgColor: const Color(0xFFFCE4EC),
              icon: Icons.handshake_outlined,
              onTap: () => context.go('/finances?tab=borrow'),
            ),
            _StatCard(
              label: 'Money Owed',
              count: _formatMoney(summary.moneyOwedToMe, currencySymbol),
              color: AppColors.primaryLight,
              bgColor: AppColors.primaryLight.withOpacity(0.1),
              icon: Icons.payments_outlined,
              onTap: () => context.go('/finances?tab=money'),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Accent Border
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: bgColor,
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary.withOpacity(0.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final Color bgColor;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: bgColor,
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Icon(Icons.arrow_outward_rounded, size: 18, color: AppColors.textTertiary.withOpacity(0.5)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}