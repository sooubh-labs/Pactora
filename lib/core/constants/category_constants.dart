import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/promises/domain/promise_enums.dart';

class CategoryConfig {
  final String label;
  final IconData icon;
  final Color color;

  const CategoryConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class CategoryConstants {
  static const Map<PromiseCategory, CategoryConfig> categories = {
    PromiseCategory.task: CategoryConfig(
      label: 'Task',
      icon: Icons.check_circle_outline,
      color: AppColors.task,
    ),
    PromiseCategory.money: CategoryConfig(
      label: 'Money',
      icon: Icons.currency_rupee,
      color: AppColors.money,
    ),
    PromiseCategory.meeting: CategoryConfig(
      label: 'Meeting',
      icon: Icons.calendar_today,
      color: AppColors.meeting,
    ),
    PromiseCategory.callback: CategoryConfig(
      label: 'Callback',
      icon: Icons.phone_callback,
      color: AppColors.primary,
    ),
    PromiseCategory.delivery: CategoryConfig(
      label: 'Delivery',
      icon: Icons.local_shipping_outlined,
      color: Colors.orange,
    ),
    PromiseCategory.document: CategoryConfig(
      label: 'Document',
      icon: Icons.description_outlined,
      color: Colors.blueGrey,
    ),
    PromiseCategory.errand: CategoryConfig(
      label: 'Errand',
      icon: Icons.directions_run,
      color: Colors.brown,
    ),
    PromiseCategory.study: CategoryConfig(
      label: 'Study',
      icon: Icons.menu_book,
      color: Colors.indigo,
    ),
    PromiseCategory.personal: CategoryConfig(
      label: 'Personal',
      icon: Icons.person_outline,
      color: Colors.teal,
    ),
    PromiseCategory.other: CategoryConfig(
      label: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  };
}
