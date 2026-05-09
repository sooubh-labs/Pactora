import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_colors.dart';

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Add',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickAddButton(
                icon: Icons.handshake_outlined,
                label: 'Promise',
                color: AppColors.task,
                onTap: () {
                  context.pop();
                  context.push('/promises/add');
                },
              ),
              _QuickAddButton(
                icon: Icons.swap_horiz,
                label: 'Borrow',
                color: AppColors.borrow,
                onTap: () {
                  context.pop();
                  context.push('/borrow/add');
                },
              ),
              _QuickAddButton(
                icon: Icons.currency_rupee,
                label: 'Money',
                color: AppColors.money,
                onTap: () {
                  context.pop();
                  context.push('/money/add');
                },
              ),
            ],
          ),
          const Gap(24),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const Gap(8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
