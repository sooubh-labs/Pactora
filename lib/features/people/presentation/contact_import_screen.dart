import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/person_model.dart';
import 'person_provider.dart';

class ContactImportScreen extends ConsumerStatefulWidget {
  const ContactImportScreen({super.key});

  @override
  ConsumerState<ContactImportScreen> createState() => _ContactImportScreenState();
}

class _ContactImportScreenState extends ConsumerState<ContactImportScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      final contacts = await FastContacts.getAllContacts();
      setState(() => _contacts = contacts);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Contacts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(contact.phones.isNotEmpty ? contact.phones.first.number : 'No phone'),
                  trailing: TextButton(
                    onPressed: () => _importContact(contact),
                    child: const Text('Import'),
                  ),
                );
              },
            ),
    );
  }

  void _importContact(Contact contact) async {
    final person = Person()
      ..name = contact.displayName
      ..phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;

    await ref.read(personRepositoryProvider).savePerson(person);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.displayName} imported')),
      );
    }
  }
}
