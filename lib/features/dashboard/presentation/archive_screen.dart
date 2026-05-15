import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ads/ad_list_separator.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: Theme.of(context).brightness == Brightness.light
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search archived items...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.5)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _ArchivedList(
                    asyncValue: archivedPromises,
                    searchQuery: _searchQuery,
                    onTap: (p) => context.push('/promises/${p.id}'),
                    titleBuilder: (p) => p.title,
                    filter: (p) => p.title.toLowerCase().contains(_searchQuery),
                  ),
                  _ArchivedList(
                    asyncValue: archivedItems,
                    searchQuery: _searchQuery,
                    onTap: (i) => context.push('/borrow/${i.id}'),
                    titleBuilder: (i) => i.name,
                    filter: (i) => i.name.toLowerCase().contains(_searchQuery),
                  ),
                  _ArchivedList(
                    asyncValue: archivedRecords,
                    searchQuery: _searchQuery,
                    onTap: (r) => context.push('/money/${r.id}'),
                    titleBuilder: (r) => '${r.currency} ${r.amount}',
                    filter: (r) => 
                      r.description?.toLowerCase().contains(_searchQuery) ?? false || 
                      '${r.currency} ${r.amount}'.contains(_searchQuery),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedList<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final String searchQuery;
  final Function(T) onTap;
  final String Function(T) titleBuilder;
  final bool Function(T) filter;

  const _ArchivedList({
    required this.asyncValue,
    required this.searchQuery,
    required this.onTap,
    required this.titleBuilder,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (allData) {
        final items = searchQuery.isEmpty 
            ? allData 
            : allData.where(filter).toList();

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty ? Icons.archive_outlined : Icons.search_off_rounded,
                  size: 48,
                  color: AppColors.textTertiary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty ? 'No archived items' : 'No results found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          itemCount: items.length,
          separatorBuilder: (context, index) => AdListSeparator(
            index: index,
            defaultSeparator: const SizedBox(height: 12),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(
                  titleBuilder(item),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => onTap(item),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
