import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../people/domain/person_model.dart';
import '../../../people/presentation/person_provider.dart';
import '../../../../shared/widgets/person_avatar.dart';
import '../../../../core/theme/app_colors.dart';

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
          onTap: () => _showPicker(context, ref, people),
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

  void _showPicker(BuildContext context, WidgetRef ref, List<Person> people) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Person', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => _addNewPerson(context, ref),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                  ),
                  if (people.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No people added yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _addNewPerson(context, ref),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add First Person'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: people.length + 1,
                        itemBuilder: (context, index) {
                          if (index == people.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 20),
                                ),
                                title: const Text('Add New Person', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                                ),
                                onTap: () => _addNewPerson(context, ref),
                              ),
                            );
                          }

                          final person = people[index];
                          final isSelected = person.id == selectedPersonId;
                          return ListTile(
                            leading: PersonAvatar(name: person.name, avatarPath: person.avatarPath),
                            title: Text(person.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onTap: () {
                              onPersonSelected(person);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addNewPerson(BuildContext context, WidgetRef ref) async {
    final result = await context.push<int>('/people/add');
    if (result != null && context.mounted) {
      final newPerson = await ref.read(personRepositoryProvider).getPersonById(result);
      if (newPerson != null && context.mounted) {
        onPersonSelected(newPerson);
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }
}
