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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Item Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/borrow/edit/$id'),
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
                _buildHeader(context, item, isOverdue),
                const Gap(32),
                _buildSectionTitle(context, 'Details'),
                const Gap(16),
                _buildDetailCard([
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: item.iLent ? 'Lent to' : 'Borrowed from',
                    value: personAsync.when(
                      data: (person) => person?.name ?? 'Unknown',
                      loading: () => '...',
                      error: (_, __) => 'Error',
                    ),
                    trailing: personAsync.when(
                      data: (person) => PersonAvatar(name: person?.name ?? 'U', radius: 14),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Expected Return',
                    value: item.expectedReturn != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(item.expectedReturn!)
                        : 'No due date',
                    valueColor: isOverdue ? AppColors.error : null,
                  ),
                  _DetailRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Status',
                    value: item.status.name.toUpperCase(),
                    valueColor: isOverdue ? AppColors.error : AppColors.primary,
                  ),
                  _DetailRow(
                    icon: Icons.inventory_2_outlined,
                    label: 'Condition',
                    value: item.condition ?? 'Not specified',
                    isLast: true,
                  ),
                ]),
                if (item.notes?.isNotEmpty == true) ...[
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
                      item.notes!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
                const Gap(48),
                _buildActionButtons(context, ref, item),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildHeader(BuildContext context, BorrowItem item, bool isOverdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (item.iLent ? const Color(0xFFD81B60) : AppColors.success).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    item.iLent ? Icons.outbox_rounded : Icons.move_to_inbox_rounded,
                    size: 14,
                    color: item.iLent ? const Color(0xFFD81B60) : AppColors.success,
                  ),
                  const Gap(6),
                  Text(
                    item.iLent ? 'LENT' : 'BORROWED',
                    style: TextStyle(
                      color: item.iLent ? const Color(0xFFD81B60) : AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            _StatusBadge(status: item.status, isOverdue: isOverdue),
          ],
        ),
        const Gap(16),
        Text(
          item.name,
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, BorrowItem item) {
    return Row(
      children: [
        if (item.status == ItemStatus.active)
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _markReturned(ref, item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Mark Returned', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        if (item.status == ItemStatus.active) const Gap(12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _sendReminder(item, ref),
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

class _StatusBadge extends StatelessWidget {
  final ItemStatus status;
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
        case ItemStatus.active:
          color = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          label = 'ACTIVE';
          break;
        case ItemStatus.returned:
          color = AppColors.doneText;
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
