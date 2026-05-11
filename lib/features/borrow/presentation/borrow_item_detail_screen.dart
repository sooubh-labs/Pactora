import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/item_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'item_provider.dart';
import '../../people/presentation/person_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/person_avatar.dart';

class BorrowItemDetailScreen extends ConsumerWidget {
  final int id;

  const BorrowItemDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(borrowItemDetailProvider(id));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return const Scaffold(body: Center(child: Text('Item not found')));
        }

        final personAsync = ref.watch(personDetailProvider(item.personId));
        final isOverdue = item.expectedReturn != null &&
            item.expectedReturn!.isBefore(DateTime.now()) &&
            item.status == ItemStatus.active;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/borrow/edit/$id'),
              ),
              IconButton(
                icon: Icon(item.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                onPressed: () => _toggleArchive(ref, item),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBanner(status: item.status, isOverdue: isOverdue),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailItem(
                        icon: item.iLent ? Icons.outbox : Icons.move_to_inbox,
                        color: item.iLent ? Colors.orange : Colors.blue,
                        label: 'Type',
                        value: item.iLent ? 'I Lent' : 'I Borrowed',
                      ),
                      const Gap(16),
                      personAsync.when(
                        data: (person) => _DetailItem(
                          widget: PersonAvatar(name: person?.name ?? 'Unknown', radius: 16),
                          label: 'Person',
                          value: person?.name ?? 'Unknown',
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading person'),
                      ),
                      const Gap(16),
                      _DetailItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Due Back',
                        value: item.expectedReturn != null
                            ? DateFormat('EEEE, MMM dd, yyyy').format(item.expectedReturn!)
                            : 'No due date',
                        textColor: isOverdue ? AppColors.overdue : null,
                      ),
                      const Gap(16),
                      _DetailItem(
                        icon: Icons.info_outline,
                        label: 'Condition',
                        value: item.condition ?? 'Not specified',
                      ),
                      if (item.notes != null) ...[
                        const Gap(24),
                        const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Gap(8),
                        Text(item.notes!, style: const TextStyle(fontSize: 16)),
                      ],
                      const Gap(32),
                      Row(
                        children: [
                          if (item.status == ItemStatus.active)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _markReturned(ref, item),
                                icon: const Icon(Icons.check),
                                label: const Text('Mark Returned'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          const Gap(12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sendReminder(item, ref),
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Send Reminder'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  void _toggleArchive(WidgetRef ref, BorrowItem item) async {
    final updated = item..isArchived = !item.isArchived;
    await ref.read(itemRepositoryProvider).saveItem(updated);
  }

  void _markReturned(WidgetRef ref, BorrowItem item) async {
    final updated = item..status = ItemStatus.returned;
    await ref.read(itemRepositoryProvider).saveItem(updated);
  }

  void _sendReminder(BorrowItem item, WidgetRef ref) async {
    final person = await ref.read(personDetailProvider(item.personId).future);
    final name = person?.name ?? 'there';
    final message = 'Hey $name, just checking in on the "${item.name}" I ${item.iLent ? 'lent you' : 'borrowed from you'} 🙂';
    Share.share(message);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(itemRepositoryProvider).deleteItem(id);
              if (context.mounted) {
                context.pop();
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final ItemStatus status;
  final bool isOverdue;

  const _StatusBanner({required this.status, required this.isOverdue});

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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: color.withOpacity(0.1),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData? icon;
  final Widget? widget;
  final Color? color;
  final String label;
  final String value;
  final Color? textColor;

  const _DetailItem({
    this.icon,
    this.widget,
    this.color,
    required this.label,
    required this.value,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null)
          CircleAvatar(
            radius: 16,
            backgroundColor: (color ?? Colors.grey).withOpacity(0.1),
            child: Icon(icon, size: 16, color: color),
          )
        else if (widget != null)
          widget!,
        const Gap(12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
