import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/item_model.dart';
import '../../people/domain/person_model.dart';
import 'item_provider.dart';
import '../../promises/presentation/widgets/person_picker_field.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final BorrowItem? item;

  const AddItemScreen({super.key, this.item});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  int? _selectedPersonId;
  bool _iLent = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _notesController = TextEditingController(text: widget.item?.notes);

    if (widget.item != null) {
      _selectedPersonId = widget.item!.personId;
      _iLent = widget.item!.iLent;
      _selectedDate = widget.item!.expectedReturn;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'New Item' : 'Edit Item'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('I Lent')),
                  ButtonSegment(value: false, label: Text('I Borrowed')),
                ],
                selected: {_iLent},
                onSelectionChanged: (val) => setState(() => _iLent = val.first),
              ),
              const SizedBox(height: 16),
              PersonPickerField(
                selectedPersonId: _selectedPersonId,
                onPersonSelected: (Person person) {
                  setState(() => _selectedPersonId = person.id);
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_selectedDate == null
                      ? 'Select Date'
                      : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPersonId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a person')),
        );
        return;
      }

      final item = widget.item ?? BorrowItem()
        ..name = _nameController.text
        ..personId = _selectedPersonId!
        ..iLent = _iLent
        ..expectedReturn = _selectedDate
        ..notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.item != null) {
        item.id = widget.item!.id;
      }

      await ref.read(itemRepositoryProvider).saveItem(item);
      if (mounted) context.pop();
    }
  }
}
