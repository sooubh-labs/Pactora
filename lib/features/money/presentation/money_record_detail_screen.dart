import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/money_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'money_provider.dart';
import '../../people/presentation/person_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/person_avatar.dart';

class MoneyRecordDetailScreen extends ConsumerWidget {
  final int id;

  const MoneyRecordDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(moneyRecordDetailProvider(id));

    return recordAsync.when(
      data: (record) {
        if (record == null) {
          return const Scaffold(body: Center(child: Text('Record not found')));
        }

        final personAsync = ref.watch(personDetailProvider(record.personId));
        final isOverdue = record.dueDate != null &&
            record.dueDate!.isBefore(DateTime.now()) &&
            record.status != MoneyStatus.paid;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Money Record'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/money/edit/$id'),
              ),
              IconButton(
                icon: Icon(record.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                onPressed: () => _toggleArchive(ref, record),
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
                _StatusBanner(status: record.status, isOverdue: isOverdue),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              '${record.currency} ${record.amount}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              record.iOwe ? 'I Owe' : 'They Owe Me',
                              style: TextStyle(
                                color: record.iOwe ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(32),
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
                        label: 'Due Date',
                        value: record.dueDate != null
                            ? DateFormat('EEEE, MMM dd, yyyy').format(record.dueDate!)
                            : 'No due date',
                        textColor: isOverdue ? AppColors.overdue : null,
                      ),
                      if (record.description != null) ...[
                        const Gap(24),
                        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Gap(8),
                        Text(record.description!, style: const TextStyle(fontSize: 16)),
                      ],
                      const Gap(32),
                      Row(
                        children: [
                          if (record.status != MoneyStatus.paid)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _markSettled(ref, record),
                                icon: const Icon(Icons.check),
                                label: const Text('Mark Settled'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          const Gap(12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sendReminder(record, ref),
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

  void _toggleArchive(WidgetRef ref, MoneyRecord record) async {
    final updated = record..isArchived = !record.isArchived;
    await ref.read(moneyRepositoryProvider).saveRecord(updated);
  }

  void _markSettled(WidgetRef ref, MoneyRecord record) async {
    final updated = record..status = MoneyStatus.paid;
    await ref.read(moneyRepositoryProvider).saveRecord(updated);
  }

  void _sendReminder(MoneyRecord record, WidgetRef ref) async {
    final person = await ref.read(personDetailProvider(record.personId).future);
    final name = person?.name ?? 'there';
    final message = 'Hey $name, just a friendly reminder about the ${record.currency} ${record.amount} ${record.iOwe ? 'I owe you' : 'you owe me'} 🙂';
    Share.share(message);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('Are you sure you want to delete this money record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(moneyRepositoryProvider).deleteRecord(id);
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
  final MoneyStatus status;
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
        case MoneyStatus.pending:
          color = AppColors.pending;
          break;
        case MoneyStatus.paid:
          color = AppColors.complete;
          break;
        case MoneyStatus.partial:
          color = Colors.blue;
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
  final String label;
  final String value;
  final Color? textColor;

  const _DetailItem({
    this.icon,
    this.widget,
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
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: Icon(icon, size: 16),
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
