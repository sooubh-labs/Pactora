import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../domain/person_model.dart';
import 'person_provider.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../../shared/widgets/person_avatar.dart';

class PersonDetailScreen extends ConsumerWidget {
  final int id;

  const PersonDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personDetailProvider(id));

    return personAsync.when(
      data: (person) {
        if (person == null) {
          return const Scaffold(body: Center(child: Text('Person not found')));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(person.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push('/people/edit/$id'),
                ),
              ],
            ),
            body: Column(
              children: [
                _PersonHeader(person: person),
                const TabBar(
                  tabs: [
                    Tab(text: 'Promises'),
                    Tab(text: 'Borrowed'),
                    Tab(text: 'Money'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _PersonPromises(personId: id),
                      _PersonItems(personId: id),
                      _PersonMoney(personId: id),
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
}

class _PersonHeader extends StatelessWidget {
  final Person person;

  const _PersonHeader({required this.person});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          PersonAvatar(name: person.name, radius: 40),
          const Gap(16),
          Text(
            person.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          if (person.phone != null) ...[
            const Gap(4),
            Text(
              person.phone!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
          if (person.notes != null) ...[
            const Gap(12),
            Text(
              person.notes!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonPromises extends ConsumerWidget {
  final int personId;
  const _PersonPromises({required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promisesAsync = ref.watch(promisesByPersonProvider(personId));
    return promisesAsync.when(
      data: (promises) => promises.isEmpty
          ? const Center(child: Text('No promises found'))
          : ListView.builder(
              itemCount: promises.length,
              itemBuilder: (context, index) {
                final promise = promises[index];
                return ListTile(
                  title: Text(promise.title),
                  subtitle: promise.dueDate != null
                      ? Text('Due: ${DateFormat('MMM dd').format(promise.dueDate!)}')
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/promises/${promise.id}'),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _PersonItems extends ConsumerWidget {
  final int personId;
  const _PersonItems({required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsByPersonProvider(personId));
    return itemsAsync.when(
      data: (items) => items.isEmpty
          ? const Center(child: Text('No items found'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.iLent ? 'I Lent' : 'I Borrowed'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/borrow/${item.id}'),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _PersonMoney extends ConsumerWidget {
  final int personId;
  const _PersonMoney({required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsByPersonProvider(personId));
    return recordsAsync.when(
      data: (records) => records.isEmpty
          ? const Center(child: Text('No money records found'))
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text('${record.currency} ${record.amount}'),
                  subtitle: Text(record.iOwe ? 'I Owe' : 'They Owe Me'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/money/${record.id}'),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
