import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

        return TabBarView(
          children: [
            _ItemList(items: items),
            _ItemList(items: items.where((i) => i.status == ItemStatus.active).toList()),
            _ItemList(items: items.where((i) => i.status == ItemStatus.overdue).toList()),
            _ItemList(items: items.where((i) => i.status == ItemStatus.returned).toList()),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No items found', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(item: item);
      },
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final BorrowItem item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = item.expectedReturn != null && item.expectedReturn!.isBefore(DateTime.now()) && item.status == ItemStatus.active;
    final color = item.iLent ? AppColors.borrow : AppColors.info;

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
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.iLent ? Icons.outbox_rounded : Icons.move_to_inbox_rounded,
              color: color,
              size: 24,
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.iLent ? 'I Lent' : 'I Borrowed',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              ),
              if (item.expectedReturn != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, size: 14, color: isOverdue ? AppColors.overdue : AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(item.expectedReturn!),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isOverdue ? AppColors.overdue : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          trailing: _StatusChip(status: item.status, isOverdue: isOverdue),
          onTap: () => context.push('/borrow/${item.id}'),
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
    Color color = AppColors.textTertiary;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      color = AppColors.overdue;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case ItemStatus.active:
          color = AppColors.active;
          break;
        case ItemStatus.returned:
          color = AppColors.complete;
          label = 'RETURNED';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
