import 'package:flutter/material.dart';
import 'dart:io';
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Promise Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/promises/edit/$id'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, promise, config, isOverdue),
                const Gap(32),
                _buildSectionTitle(context, 'Details'),
                const Gap(16),
                _buildDetailCard([
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Involved with',
                    value: personAsync.when(
                      data: (person) => person?.name ?? 'Unknown',
                      loading: () => '...',
                      error: (_, __) => 'Error',
                    ),
                    trailing: personAsync.when(
                      data: (person) => PersonAvatar(name: person?.name ?? 'U', radius: 14, avatarPath: person?.avatarPath),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due Date',
                    value: promise.dueDate != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(promise.dueDate!)
                        : 'No due date',
                    valueColor: isOverdue ? AppColors.error : null,
                  ),
                  if (promise.dueTime != null)
                    _DetailRow(
                      icon: Icons.access_time_rounded,
                      label: 'Due Time',
                      value: DateFormat('hh:mm a').format(promise.dueTime!),
                    ),
                  _DetailRow(
                    icon: Icons.priority_high_rounded,
                    label: 'Priority Level',
                    value: promise.priority.name.toUpperCase(),
                    valueColor: _getPriorityColor(promise.priority),
                  ),
                  _DetailRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Type',
                    value: promise.iMadeThisPromise ? 'I promised them' : 'They promised me',
                    isLast: true,
                  ),
                ]),
                if (promise.notes?.isNotEmpty == true || promise.description?.isNotEmpty == true) ...[
                  const Gap(32),
                  _buildSectionTitle(context, 'Notes'),
                  const Gap(16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      promise.description?.isNotEmpty == true ? promise.description! : promise.notes!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
                if (promise.attachmentPaths.isNotEmpty) ...[
                  const Gap(32),
                  _buildSectionTitle(context, 'Attachments'),
                  const Gap(16),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: promise.attachmentPaths.length,
                      separatorBuilder: (context, index) => const Gap(12),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(promise.attachmentPaths[index]),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const Gap(48),
                _buildActionButtons(context, ref, promise),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildHeader(BuildContext context, Promise promise, CategoryConfig config, bool isOverdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(config.icon, size: 14, color: config.color),
                  const Gap(6),
                  Text(
                    config.label.toUpperCase(),
                    style: TextStyle(
                      color: config.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            _StatusBadge(status: promise.status, isOverdue: isOverdue),
          ],
        ),
        const Gap(16),
        Text(
          promise.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Promise promise) {
    return Row(
      children: [
        if (promise.status == PromiseStatus.pending)
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _markComplete(context, ref, promise),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Mark Complete', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        if (promise.status == PromiseStatus.pending) const Gap(12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _sendReminder(promise, ref),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text('Send Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high: return AppColors.error;
      case Priority.medium: return AppColors.warning;
      case Priority.low: return AppColors.success;
    }
  }

  void _markComplete(BuildContext context, WidgetRef ref, Promise promise) async {
    await ref.read(promiseRepositoryProvider).completePromise(promise);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Promise marked as completed!')),
      );
      Navigator.of(context).pop();
    }
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

class _StatusBadge extends StatelessWidget {
  final PromiseStatus status;
  final bool isOverdue;

  const _StatusBadge({required this.status, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.pendingText;
    Color bgColor = AppColors.pendingBg;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      color = AppColors.overdueText;
      bgColor = AppColors.overdueBg;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case PromiseStatus.pending:
          color = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          break;
        case PromiseStatus.completed:
          color = AppColors.doneText;
          bgColor = AppColors.doneBg;
          label = 'COMPLETED';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.6)),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                    const Gap(2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 0.5, indent: 64),
      ],
    );
  }
}
