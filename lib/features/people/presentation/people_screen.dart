import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../domain/person_model.dart';
import 'person_provider.dart';

class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(allPeopleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: peopleAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No people yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/people/add'),
                    child: const Text('Add someone'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: people.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final person = people[index];
              return _PersonCard(person: person);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/people/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: PersonAvatar(name: person.name),
        title: Text(person.name),
        subtitle: person.phone != null ? Text(person.phone!) : null,
        onTap: () => context.push('/people/${person.id}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
