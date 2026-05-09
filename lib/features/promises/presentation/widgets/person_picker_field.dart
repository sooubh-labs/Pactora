import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../people/domain/person_model.dart';
import '../../../people/presentation/person_provider.dart';
import '../../../../shared/widgets/person_avatar.dart';

class PersonPickerField extends ConsumerWidget {
  final int? selectedPersonId;
  final ValueChanged<Person> onPersonSelected;

  const PersonPickerField({
    super.key,
    required this.selectedPersonId,
    required this.onPersonSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleAsync = ref.watch(allPeopleProvider);

    return peopleAsync.when(
      data: (people) {
        final selectedPerson = people.where((p) => p.id == selectedPersonId).firstOrNull;

        return InkWell(
          onTap: () => _showPicker(context, people),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Person',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            child: Text(
              selectedPerson?.name ?? 'Select Person',
              style: TextStyle(
                color: selectedPerson == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (err, stack) => Text('Error loading people: $err'),
    );
  }

  void _showPicker(BuildContext context, List<Person> people) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Select Person', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: people.length,
                    itemBuilder: (context, index) {
                      final person = people[index];
                      return ListTile(
                        leading: PersonAvatar(name: person.name),
                        title: Text(person.name),
                        onTap: () {
                          onPersonSelected(person);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
