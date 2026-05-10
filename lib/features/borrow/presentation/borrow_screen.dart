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

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Overdue'),
              Tab(text: 'Returned'),
            ],
          ),
          Expanded(
            child: itemsAsync.when(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemList extends ConsumerWidget {
  final List<BorrowItem> items;

  const _ItemList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await ref.read(itemRepositoryProvider).deleteItem(item.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: item.status == ItemStatus.active ? ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final updated = item..status = ItemStatus.returned;
              await ref.read(itemRepositoryProvider).saveItem(updated);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Returned',
          ),
        ],
      ) : null,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.iLent ? Colors.orange.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
            child: Icon(
              item.iLent ? Icons.outbox : Icons.move_to_inbox,
              color: item.iLent ? Colors.orange : Colors.blue,
            ),
          ),
          title: Text(item.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.iLent ? 'I Lent' : 'I Borrowed'),
              if (item.expectedReturn != null)
                Text(
                  'Due: ${DateFormat('MMM dd').format(item.expectedReturn!)}',
                  style: TextStyle(color: isOverdue ? AppColors.overdue : null),
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
    Color color = Colors.grey;
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
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
