import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          Text(
            'GENERAL',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.people_outline_rounded,
            title: 'People',
            color: AppColors.primaryLight,
            onTap: () => context.push('/people'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.calendar_month_rounded,
            title: 'Calendar',
            color: AppColors.task,
            onTap: () => context.push('/calendar'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.analytics_outlined,
            title: 'Reports & Stats',
            color: AppColors.money,
            onTap: () => context.push('/stats'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.history_rounded,
            title: 'Activity Log',
            color: AppColors.meeting,
            onTap: () => context.push('/timeline'),
          ),
          const SizedBox(height: 24),
          Text(
            'SYSTEM',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.archive_outlined,
            title: 'Archive',
            color: AppColors.textTertiary,
            onTap: () => context.push('/archive'),
          ),
          _buildMenuTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            color: AppColors.textSecondary,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Manage your account',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
