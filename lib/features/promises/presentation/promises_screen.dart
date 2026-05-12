import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import 'promise_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/horizontal_calendar.dart';

class PromisesScreen extends ConsumerStatefulWidget {
  const PromisesScreen({super.key});

  @override
  ConsumerState<PromisesScreen> createState() => _PromisesScreenState();
}

enum PromiseSortType { date, priority, category }

class _PromisesScreenState extends ConsumerState<PromisesScreen> {
  DateTime? _selectedDate;
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: Overdue, 3: Done
  PromiseSortType _currentSort = PromiseSortType.date;

  @override
  Widget build(BuildContext context) {
    final promisesAsync = ref.watch(allPromisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promises'),
        actions: [
          PopupMenuButton<PromiseSortType>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (sortType) {
              setState(() => _currentSort = sortType);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: PromiseSortType.date,
                child: Text('Sort by Date (Urgency)'),
              ),
              const PopupMenuItem(
                value: PromiseSortType.priority,
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem(
                value: PromiseSortType.category,
                child: Text('Sort by Category'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            promisesAsync.when(
              data: (promises) => HorizontalCalendar(
                activeDates: promises
                    .where((p) => p.dueDate != null)
                    .map((p) => p.dueDate!)
                    .toList(),
                initialDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
              loading: () => const SizedBox(height: 120),
              error: (_, __) => const SizedBox(height: 120),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _selectedDate == null 
                    ? 'All Promises' 
                    : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            _buildFilterPills(),
            const SizedBox(height: 16),
            Expanded(
              child: promisesAsync.when(
                data: (promises) {
                  final filteredPromises = _selectedDate == null 
                    ? promises 
                    : promises.where((p) =>
                        p.dueDate != null && isSameDay(p.dueDate, _selectedDate)
                      ).toList();

                  List<Promise> finalPromises = filteredPromises;
                  switch (_selectedFilterIndex) {
                    case 1:
                      finalPromises = filteredPromises.where((p) => p.status == PromiseStatus.pending).toList();
                      break;
                    case 2:
                      finalPromises = filteredPromises.where((p) => p.status == PromiseStatus.overdue).toList();
                      break;
                    case 3:
                      finalPromises = filteredPromises.where((p) => p.status == PromiseStatus.completed).toList();
                      break;
                  }

                  // Sorting logic
                  finalPromises = List.from(finalPromises);
                  switch (_currentSort) {
                    case PromiseSortType.priority:
                      finalPromises.sort((a, b) => b.priority.index.compareTo(a.priority.index)); // High (2) to Low (0)
                      break;
                    case PromiseSortType.category:
                      finalPromises.sort((a, b) => a.category.name.compareTo(b.category.name));
                      break;
                    case PromiseSortType.date:
                      finalPromises.sort((a, b) {
                        if (a.dueDate == null && b.dueDate == null) return 0;
                        if (a.dueDate == null) return 1;
                        if (b.dueDate == null) return -1;
                        return a.dueDate!.compareTo(b.dueDate!);
                      });
                      break;
                  }

                  return _PromiseList(promises: finalPromises);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = ['All', 'Pending', 'Overdue', 'Done'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.asMap().entries.map((entry) {
          final isSelected = _selectedFilterIndex == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PromiseList extends ConsumerWidget {
  final List<Promise> promises;

  const _PromiseList({required this.promises});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (promises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No promises found', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 140), // Bottom padding for floating nav
      itemCount: promises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final promise = promises[index];
        return _PromiseCard(promise: promise);
      },
    );
  }
}

class _PromiseCard extends ConsumerStatefulWidget {
  final Promise promise;

  const _PromiseCard({required this.promise});

  @override
  ConsumerState<_PromiseCard> createState() => _PromiseCardState();
}

class _PromiseCardState extends ConsumerState<_PromiseCard> {
  bool _isExpanded = false;

  IconData _getCategoryIcon(PromiseCategory category) {
    switch (category) {
      case PromiseCategory.money: return Icons.attach_money_rounded;
      case PromiseCategory.task: return Icons.check_circle_outline_rounded;
      case PromiseCategory.meeting: return Icons.groups_rounded;
      case PromiseCategory.callback: return Icons.phone_callback_rounded;
      case PromiseCategory.delivery: return Icons.local_shipping_rounded;
      case PromiseCategory.document: return Icons.description_rounded;
      case PromiseCategory.errand: return Icons.shopping_bag_rounded;
      case PromiseCategory.study: return Icons.menu_book_rounded;
      case PromiseCategory.personal: return Icons.person_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high: return AppColors.error;
      case Priority.medium: return AppColors.warning;
      case Priority.low: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final promise = widget.promise;
    final isOverdue = promise.dueDate != null && promise.dueDate!.isBefore(DateTime.now()) && promise.status == PromiseStatus.pending;
    
    // Determine card accent and background based on status
    Color accentColor = AppColors.pendingText; // Blue default
    Color iconBgColor = AppColors.pendingBg;
    if (promise.status == PromiseStatus.completed) {
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
              await ref.read(promiseRepositoryProvider).deletePromise(promise.id);
            },
            backgroundColor: AppColors.error.withOpacity(0.1),
            foregroundColor: AppColors.error,
            borderRadius: BorderRadius.circular(24),
            child: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      startActionPane: promise.status == PromiseStatus.pending ? ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await ref.read(promiseRepositoryProvider).completePromise(promise);
            },
            backgroundColor: AppColors.success.withOpacity(0.1),
            foregroundColor: AppColors.success,
            borderRadius: BorderRadius.circular(24),
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ) : null,
      child: GestureDetector(
        onTap: () => context.push('/promises/${promise.id}'),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 100) {
            setState(() => _isExpanded = true);
          } else if (details.primaryVelocity! < -100) {
            setState(() => _isExpanded = false);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Category Icon
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: iconBgColor,
                            child: Icon(_getCategoryIcon(promise.category), color: accentColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        promise.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: promise.status == PromiseStatus.completed ? AppColors.textSecondary : AppColors.textPrimary,
                                          decoration: promise.status == PromiseStatus.completed ? TextDecoration.lineThrough : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (promise.status != PromiseStatus.completed)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(promise.priority),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        promise.dueDate != null ? 'Due: ${DateFormat('E, MMM d - h:mm a').format(promise.dueDate!)}' : 'No date',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isOverdue ? AppColors.overdueText : AppColors.textSecondary,
                                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _StatusChip(status: promise.status, isOverdue: isOverdue),
                              const SizedBox(height: 8),
                              if (promise.description?.isNotEmpty == true || promise.notes?.isNotEmpty == true)
                                GestureDetector(
                                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                                  child: Icon(
                                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.textTertiary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _isExpanded && (promise.description?.isNotEmpty == true || promise.notes?.isNotEmpty == true)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16.0, left: 64.0),
                                child: Text(
                                  promise.description?.isNotEmpty == true ? promise.description! : promise.notes!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PromiseStatus status;
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
        case PromiseStatus.pending:
          textColor = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          break;
        case PromiseStatus.completed:
          textColor = AppColors.doneText;
          bgColor = AppColors.doneBg;
          label = 'DONE';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor, 
          fontSize: 10, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
