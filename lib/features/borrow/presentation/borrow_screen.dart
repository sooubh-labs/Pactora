import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../domain/item_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'item_provider.dart';
import '../../../core/theme/app_colors.dart';

class BorrowScreen extends ConsumerWidget {
  final DateTime? selectedDate;
  const BorrowScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsProvider);

    return itemsAsync.when(
      data: (allItems) {
        final items = selectedDate == null 
          ? allItems 
          : allItems.where((i) => i.expectedReturn != null && isSameDay(i.expectedReturn, selectedDate)).toList();

        final lentItems = items.where((i) => i.iLent && i.status == ItemStatus.active).length;
        final borrowedItems = items.where((i) => !i.iLent && i.status == ItemStatus.active).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(lentItems, borrowedItems),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ItemList(items: items),
              const SizedBox(height: 100), // padding for floating nav
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSummaryCards(int lentItems, int borrowedItems) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC), // Very light pink
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFD81B60).withOpacity(0.1),
                      child: const Icon(Icons.outbox_rounded, size: 16, color: Color(0xFFD81B60)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'I Lent',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$lentItems',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), // Very light green
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      child: const Icon(Icons.move_to_inbox_rounded, size: 16, color: AppColors.success),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'I Borrowed',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$borrowedItems',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemList extends ConsumerWidget {
  final List<BorrowItem> items;

  const _ItemList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No items found', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _ItemCard(item: item),
      )).toList(),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final BorrowItem item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = item.expectedReturn != null && item.expectedReturn!.isBefore(DateTime.now()) && item.status == ItemStatus.active;
    
    // Determine card accent and background based on status
    Color accentColor = AppColors.pendingText; // Blue default
    Color iconBgColor = AppColors.pendingBg;
    if (item.status == ItemStatus.returned) {
      accentColor = AppColors.doneText;
      iconBgColor = AppColors.doneBg;
    } else if (isOverdue) {
      accentColor = AppColors.overdueText;
      iconBgColor = AppColors.overdueBg;
    }

    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await ref.read(itemRepositoryProvider).deleteItem(item.id);
            },
            backgroundColor: AppColors.error.withOpacity(0.1),
            foregroundColor: AppColors.error,
            borderRadius: BorderRadius.circular(32),
            child: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      startActionPane: item.status == ItemStatus.active ? ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              final updated = item..status = ItemStatus.returned;
              await ref.read(itemRepositoryProvider).saveItem(updated);
            },
            backgroundColor: AppColors.success.withOpacity(0.1),
            foregroundColor: AppColors.success,
            borderRadius: BorderRadius.circular(32),
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Border
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      // Avatar mock (initials)
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: iconBgColor,
                        child: Text(
                          'SJ', // Mock initials
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: item.status == ItemStatus.returned ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.iLent ? 'Lent to someone' : 'Borrowed from someone',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatusChip(status: item.status, isOverdue: isOverdue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ItemStatus status;
  final bool isOverdue;

  const _StatusChip({required this.status, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.pendingText;
    Color bgColor = AppColors.pendingBg;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      textColor = AppColors.overdueText;
      bgColor = AppColors.overdueBg;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case ItemStatus.active:
          textColor = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          label = 'ACTIVE';
          break;
        case ItemStatus.returned:
          textColor = AppColors.doneText;
          bgColor = AppColors.doneBg;
          label = 'RETURNED';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor, 
          fontSize: 9, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
