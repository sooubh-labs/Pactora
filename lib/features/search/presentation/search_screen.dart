import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'search_provider.dart';
import '../../../shared/widgets/person_avatar.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(globalSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search promises, people...',
            border: InputBorder.none,
          ),
          onChanged: (val) => ref.read(searchQueryProvider.notifier).updateQuery(val),
        ),
      ),
      body: resultsAsync.when(
        data: (results) {
          if (query.isEmpty) {
            return const Center(child: Text('Type to search'));
          }
          if (results.isEmpty) {
            return const Center(child: Text('No results found'));
          }

          return ListView(
            children: [
              if (results.promises.isNotEmpty) ...[
                const _SearchHeader(title: 'PROMISES'),
                ...results.promises.map((p) => ListTile(
                  leading: const Icon(Icons.handshake_outlined),
                  title: Text(p.title),
                  onTap: () => context.push('/promises/${p.id}'),
                )),
              ],
              if (results.people.isNotEmpty) ...[
                const _SearchHeader(title: 'PEOPLE'),
                ...results.people.map((p) => ListTile(
                  leading: PersonAvatar(name: p.name, radius: 16, avatarPath: p.avatarPath),
                  title: Text(p.name),
                  onTap: () => context.push('/people/${p.id}'),
                )),
              ],
              if (results.items.isNotEmpty) ...[
                const _SearchHeader(title: 'BORROWED ITEMS'),
                ...results.items.map((i) => ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(i.name),
                  onTap: () => context.push('/borrow/${i.id}'),
                )),
              ],
              if (results.records.isNotEmpty) ...[
                const _SearchHeader(title: 'MONEY'),
                ...results.records.map((r) => ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text('${r.currency} ${r.amount}'),
                  subtitle: r.description != null ? Text(r.description!) : null,
                  onTap: () => context.push('/money/${r.id}'),
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final String title;
  const _SearchHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
