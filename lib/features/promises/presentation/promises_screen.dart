import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import 'promise_provider.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/horizontal_calendar.dart';

class PromisesScreen extends ConsumerStatefulWidget {
  const PromisesScreen({super.key});

  @override
  ConsumerState<PromisesScreen> createState() => _PromisesScreenState();
}

class _PromisesScreenState extends ConsumerState<PromisesScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final promisesAsync = ref.watch(allPromisesProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Promises'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () => context.push('/search'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
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
              loading: () => const SizedBox(height: 110),
              error: (_, __) => const SizedBox(height: 110),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  const TabBar(
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.symmetric(horizontal: 12),
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Overdue'),
                      Tab(text: 'Done'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: promisesAsync.when(
                data: (promises) {
                  final filteredPromises = promises.where((p) =>
                    p.dueDate != null && isSameDay(p.dueDate, _selectedDate)
                  ).toList();

                  return TabBarView(
                    children: [
                      _PromiseList(promises: filteredPromises),
                      _PromiseList(
                          promises: filteredPromises
                              .where((p) => p.status == PromiseStatus.pending)
                              .toList()),
                      _PromiseList(
                          promises: filteredPromises
                              .where((p) => p.status == PromiseStatus.overdue)
                              .toList()),
                      _PromiseList(
                          promises: filteredPromises
                              .where((p) => p.status == PromiseStatus.completed)
                              .toList()),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/promises/add'),
          child: const Icon(Icons.add_rounded),
        ),
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
            Text('No promises for this date', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: promises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final promise = promises[index];
        return _PromiseCard(promise: promise);
      },
    );
  }
}

class _PromiseCard extends ConsumerWidget {
  final Promise promise;

  const _PromiseCard({required this.promise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = CategoryConstants.categories[promise.category]!;
    final isOverdue = promise.dueDate != null && promise.dueDate!.isBefore(DateTime.now()) && promise.status == PromiseStatus.pending;

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
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(config.icon, color: config.color, size: 24),
          ),
          title: Text(
            promise.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: promise.status == PromiseStatus.completed ? TextDecoration.lineThrough : null,
              color: promise.status == PromiseStatus.completed ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: isOverdue ? AppColors.overdue : AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(promise.dueDate!),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOverdue ? AppColors.overdue : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          trailing: _StatusChip(status: promise.status, isOverdue: isOverdue),
          onTap: () => context.push('/promises/${promise.id}'),
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
    Color color = AppColors.textTertiary;
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
          label = 'DONE';
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
