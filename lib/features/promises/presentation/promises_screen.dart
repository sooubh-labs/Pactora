import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import 'promise_provider.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/theme/app_colors.dart';

class PromisesScreen extends ConsumerWidget {
  const PromisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promisesAsync = ref.watch(allPromisesProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Promises'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Overdue'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search'),
            ),
          ],
        ),
        body: promisesAsync.when(
          data: (promises) {
            return TabBarView(
              children: [
                _PromiseList(promises: promises),
                _PromiseList(promises: promises.where((p) => p.status == PromiseStatus.pending).toList()),
                _PromiseList(promises: promises.where((p) => p.status == PromiseStatus.overdue).toList()),
                _PromiseList(promises: promises.where((p) => p.status == PromiseStatus.completed).toList()),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/promises/add'),
          child: const Icon(Icons.add),
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
      return const Center(child: Text('No promises found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: promises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
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
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await ref.read(promiseRepositoryProvider).deletePromise(promise.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: promise.status == PromiseStatus.pending ? ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await ref.read(promiseRepositoryProvider).completePromise(promise);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Complete',
          ),
        ],
      ) : null,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: config.color.withValues(alpha: 0.2),
            child: Icon(config.icon, color: config.color),
          ),
          title: Text(
            promise.title,
            style: TextStyle(
              decoration: promise.status == PromiseStatus.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (promise.dueDate != null)
                Text(
                  'Due: ${DateFormat('MMM dd').format(promise.dueDate!)}',
                  style: TextStyle(color: isOverdue ? AppColors.overdue : null),
                ),
            ],
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
