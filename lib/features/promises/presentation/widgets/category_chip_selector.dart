import 'package:flutter/material.dart';
import '../../domain/promise_enums.dart';
import '../../../../core/constants/category_constants.dart';

class CategoryChipSelector extends StatelessWidget {
  final PromiseCategory selectedCategory;
  final ValueChanged<PromiseCategory> onCategorySelected;

  const CategoryChipSelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PromiseCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = PromiseCategory.values[index];
          final config = CategoryConstants.categories[category]!;
          final isSelected = category == selectedCategory;

          return FilterChip(
            label: Text(config.label),
            avatar: Icon(config.icon, size: 18, color: isSelected ? Colors.white : config.color),
            selected: isSelected,
            onSelected: (_) => onCategorySelected(category),
            selectedColor: config.color,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          );
        },
      ),
    );
  }
}
