import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import 'promise_provider.dart';
import '../../people/presentation/person_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/category_constants.dart';
import '../../../shared/widgets/person_avatar.dart';

class PromiseDetailScreen extends ConsumerWidget {
  final int id;

  const PromiseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promiseAsync = ref.watch(promiseDetailProvider(id));

    return promiseAsync.when(
      data: (promise) {
        if (promise == null) {
          return const Scaffold(body: Center(child: Text('Promise not found')));
        }

        final personAsync = ref.watch(personDetailProvider(promise.personId));
        final config = CategoryConstants.categories[promise.category]!;
        final isOverdue = promise.dueDate != null &&
            promise.dueDate!.isBefore(DateTime.now()) &&
            promise.status == PromiseStatus.pending;

        return Scaffold(
          appBar: AppBar(
            title: Text(promise.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/promises/edit/$id'),
              ),
              IconButton(
                icon: Icon(promise.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                onPressed: () => _toggleArchive(ref, promise),
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
                _StatusBanner(status: promise.status, isOverdue: isOverdue),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailItem(
                        icon: config.icon,
                        color: config.color,
                        label: 'Category',
                        value: config.label,
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
                        label: 'Due Date',
                        value: promise.dueDate != null
                            ? DateFormat('EEEE, MMM dd, yyyy').format(promise.dueDate!)
                            : 'No due date',
                        textColor: isOverdue ? AppColors.overdue : null,
                      ),
                      if (promise.dueTime != null) ...[
                        const Gap(16),
                        _DetailItem(
                          icon: Icons.access_time,
                          label: 'Due Time',
                          value: DateFormat('hh:mm a').format(promise.dueTime!),
                        ),
                      ],
                      const Gap(16),
                      _DetailItem(
                        icon: Icons.priority_high,
                        label: 'Priority',
                        value: promise.priority.name.toUpperCase(),
                        textColor: _getPriorityColor(promise.priority),
                      ),
                      const Gap(16),
                      _DetailItem(
                        icon: Icons.info_outline,
                        label: 'Type',
                        value: promise.iMadeThisPromise ? 'I promised them' : 'They promised me',
                      ),
                      if (promise.notes != null) ...[
                        const Gap(24),
                        const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Gap(8),
                        Text(promise.notes!, style: const TextStyle(fontSize: 16)),
                      ],
                      const Gap(32),
                      Row(
                        children: [
                          if (promise.status == PromiseStatus.pending)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _markComplete(ref, promise),
                                icon: const Icon(Icons.check),
                                label: const Text('Mark Complete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          const Gap(12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _sendReminder(promise, ref),
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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  void _toggleArchive(WidgetRef ref, Promise promise) async {
    final updated = promise..isArchived = !promise.isArchived;
    await ref.read(promiseRepositoryProvider).savePromise(updated);
  }

  void _markComplete(WidgetRef ref, Promise promise) async {
    await ref.read(promiseRepositoryProvider).completePromise(promise);
  }

  void _sendReminder(Promise promise, WidgetRef ref) async {
    final person = await ref.read(personDetailProvider(promise.personId).future);
    final name = person?.name ?? 'there';
    final message = 'Hey $name, just a friendly reminder about "${promise.title}" 🙂';
    Share.share(message);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promise?'),
        content: const Text('Are you sure you want to delete this promise?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(promiseRepositoryProvider).deletePromise(id);
              if (context.mounted) {
                context.pop(); // Close dialog
                context.pop(); // Go back to list
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
  final PromiseStatus status;
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
        case PromiseStatus.pending:
          color = AppColors.pending;
          break;
        case PromiseStatus.completed:
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
