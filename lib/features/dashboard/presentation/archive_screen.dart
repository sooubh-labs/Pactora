import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../../core/ads/banner_ad_widget.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedPromises = ref.watch(archivedPromisesProvider);
    final archivedItems = ref.watch(archivedItemsProvider);
    final archivedRecords = ref.watch(archivedMoneyRecordsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Archive'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Promises'),
              Tab(text: 'Borrowed'),
              Tab(text: 'Money'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ArchivedList(
              asyncValue: archivedPromises,
              onTap: (p) => context.push('/promises/${p.id}'),
              titleBuilder: (p) => p.title,
            ),
            _ArchivedList(
              asyncValue: archivedItems,
              onTap: (i) => context.push('/borrow/${i.id}'),
              titleBuilder: (i) => i.name,
            ),
            _ArchivedList(
              asyncValue: archivedRecords,
              onTap: (r) => context.push('/money/${r.id}'),
              titleBuilder: (r) => '${r.currency} ${r.amount}',
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedList<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Function(T) onTap;
  final String Function(T) titleBuilder;

  const _ArchivedList({
    required this.asyncValue,
    required this.onTap,
    required this.titleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('No archived items'));
        }
        return ListView.separated(
          itemCount: items.length,
          separatorBuilder: (context, index) {
            if ((index + 1) % 5 == 0) {
              return const Column(
                children: [
                  Divider(),
                  BannerAdWidget(),
                  Divider(),
                ],
              );
            }
            return const Divider();
          },
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(titleBuilder(item)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onTap(item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
