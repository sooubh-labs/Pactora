import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/person_repository.dart';
import '../domain/person_model.dart';
import '../../../core/theme/app_colors.dart';

class ContactImportScreen extends ConsumerStatefulWidget {
  const ContactImportScreen({super.key});

  @override
  ConsumerState<ContactImportScreen> createState() => _ContactImportScreenState();
}

class _ContactImportScreenState extends ConsumerState<ContactImportScreen> {
  List<Contact>? _contacts;
  final Set<String> _selectedContactIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts = await FastContacts.getAllContacts();
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contacts permission is required')),
          );
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _contacts = [];
        });
      }
    }
  }

  Future<void> _importSelected() async {
    if (_selectedContactIds.isEmpty || _contacts == null) return;

    setState(() => _isLoading = true);

    final selectedContacts = _contacts!
        .where((c) => _selectedContactIds.contains(c.id))
        .toList();

    int successCount = 0;
    List<String> failedNames = [];

    final repo = PersonRepository();

    for (final contact in selectedContacts) {
      try {
        final String displayName = contact.displayName;
        final String? phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;
        final String? email = contact.emails.isNotEmpty ? contact.emails.first.address : null;

        if (displayName.isEmpty && phone == null) {
          failedNames.add('Unnamed contact');
          continue;
        }

        final person = Person()
          ..name = displayName.isNotEmpty ? displayName : (phone ?? 'Unknown Contact')
          ..phone = phone
          ..email = email;
        
        await repo.savePerson(person);
        successCount++;
      } catch (e) {
        failedNames.add(contact.displayName.isNotEmpty ? contact.displayName : 'Unknown');
      }
    }

    if (mounted) {
      String message = 'Successfully imported $successCount contacts.';
      if (failedNames.isNotEmpty) {
        message += '\n\nIssues with: \n${failedNames.take(5).join(", ")}';
        if (failedNames.length > 5) message += ' and ${failedNames.length - 5} more...';
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Import Complete'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // close dialog
                context.go('/people'); // return to people list
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts?.where((c) {
      final nameMatch = c.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
      final phoneMatch = c.phones.any((p) => p.number.contains(_searchQuery));
      return nameMatch || phoneMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Contacts'),
        actions: [
          if (_contacts != null && _contacts!.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedContactIds.length == _contacts!.length) {
                    _selectedContactIds.clear();
                  } else {
                    _selectedContactIds.addAll(_contacts!.map((c) => c.id));
                  }
                });
              },
              child: Text(
                _selectedContactIds.length == _contacts!.length ? 'Deselect All' : 'Select All',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredContacts == null || filteredContacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('No contacts found'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          final isSelected = _selectedContactIds.contains(contact.id);
                          final hasPhone = contact.phones.isNotEmpty;
                          
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedContactIds.add(contact.id);
                                } else {
                                  _selectedContactIds.remove(contact.id);
                                }
                              });
                            },
                            title: Text(
                              contact.displayName.isNotEmpty ? contact.displayName : 'Unnamed Contact',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: hasPhone
                                ? Text(contact.phones.first.number)
                                : const Text('No phone number', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            secondary: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            activeColor: AppColors.primary,
                            checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedContactIds.isEmpty || _isLoading ? null : _importSelected,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              _isLoading ? 'Importing...' : 'Import Selected (${_selectedContactIds.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
