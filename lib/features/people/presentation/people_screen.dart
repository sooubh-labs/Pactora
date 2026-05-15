import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ads/ad_list_separator.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../domain/person_model.dart';
import 'person_provider.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#'.split('');
  
  // Approximate heights for scrolling
  final double _itemHeight = 88.0; // Card + Separator
  final double _adHeight = 70.0; // Estimated BannerAdWidget + extra separators

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLetter(String letter, List<Person> people) {
    int index = -1;
    if (letter == '#') {
      index = people.indexWhere((p) => p.name.isEmpty || !RegExp(r'[A-Z]').hasMatch(p.name[0].toUpperCase()));
    } else {
      index = people.indexWhere((p) => p.name.toUpperCase().startsWith(letter));
    }

    if (index != -1) {
      // Calculate offset considering ads
      final adInterval = 5;
      int adCount = index ~/ adInterval;
      double offset = (index * _itemHeight) + (adCount * _adHeight);
      
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final peopleAsync = ref.watch(allPeopleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_page_outlined),
            onPressed: () => context.push('/people/import'),
            tooltip: 'Import Contacts',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: peopleAsync.when(
        data: (people) {
          if (people.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 8, 40, 140),
                itemCount: people.length,
                separatorBuilder: (context, index) => AdListSeparator(index: index),
                itemBuilder: (context, index) {
                  final person = people[index];
                  return _PersonCard(person: person);
                },
              ),
              Positioned(
                right: 0,
                top: 20,
                bottom: 140,
                width: 32,
                child: _AlphabetScrollbar(
                  alphabet: _alphabet,
                  onLetterSelected: (letter) => _scrollToLetter(letter, people),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/people/add'),
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded, size: 64, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            Text(
              'No people yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your contacts to start tracking promises and records together.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.push('/people/add'),
                  icon: const Icon(Icons.person_add_rounded),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.push('/people/import'),
                  icon: const Icon(Icons.contact_page_outlined),
                  label: const Text('Import'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlphabetScrollbar extends StatelessWidget {
  final List<String> alphabet;
  final ValueChanged<String> onLetterSelected;

  const _AlphabetScrollbar({
    required this.alphabet,
    required this.onLetterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemHeight = constraints.maxHeight / alphabet.length;
        
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            int index = (details.localPosition.dy / itemHeight).floor();
            if (index >= 0 && index < alphabet.length) {
              onLetterSelected(alphabet[index]);
            }
          },
          onTapDown: (details) {
            int index = (details.localPosition.dy / itemHeight).floor();
            if (index >= 0 && index < alphabet.length) {
              onLetterSelected(alphabet[index]);
            }
          },
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: alphabet.map((letter) {
                return SizedBox(
                  height: itemHeight,
                  child: Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Person person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        leading: PersonAvatar(name: person.name, avatarPath: person.avatarPath),
        title: Text(
          person.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: person.phone != null 
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(person.phone!, style: Theme.of(context).textTheme.bodyMedium),
            ) 
          : null,
        onTap: () => context.push('/people/${person.id}'),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary.withOpacity(0.5)),
      ),
    );
  }
}
