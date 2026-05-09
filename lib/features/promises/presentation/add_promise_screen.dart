import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import '../../people/domain/person_model.dart';
import 'promise_provider.dart';
import 'widgets/category_chip_selector.dart';
import 'widgets/person_picker_field.dart';

class AddPromiseScreen extends ConsumerStatefulWidget {
  final Promise? promise;

  const AddPromiseScreen({super.key, this.promise});

  @override
  ConsumerState<AddPromiseScreen> createState() => _AddPromiseScreenState();
}

class _AddPromiseScreenState extends ConsumerState<AddPromiseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  int? _selectedPersonId;
  PromiseCategory _selectedCategory = PromiseCategory.task;
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _iMadeThisPromise = true;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.promise?.title);
    _descriptionController = TextEditingController(text: widget.promise?.description);
    _notesController = TextEditingController(text: widget.promise?.notes);

    if (widget.promise != null) {
      _selectedPersonId = widget.promise!.personId;
      _selectedCategory = widget.promise!.category;
      _selectedPriority = widget.promise!.priority;
      _selectedDate = widget.promise!.dueDate;
      if (widget.promise!.dueTime != null) {
        _selectedTime = TimeOfDay.fromDateTime(widget.promise!.dueTime!);
      }
      _iMadeThisPromise = widget.promise!.iMadeThisPromise;
      _selectedRecurrence = widget.promise!.recurrence;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.promise == null ? 'New Promise' : 'Edit Promise'),
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
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              PersonPickerField(
                selectedPersonId: _selectedPersonId,
                onPersonSelected: (Person person) {
                  setState(() => _selectedPersonId = person.id);
                },
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CategoryChipSelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (PromiseCategory category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_selectedTime == null
                            ? 'Select Time'
                            : _selectedTime!.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
              SegmentedButton<Priority>(
                segments: const [
                  ButtonSegment(value: Priority.low, label: Text('Low')),
                  ButtonSegment(value: Priority.medium, label: Text('Med')),
                  ButtonSegment(value: Priority.high, label: Text('High')),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (val) => setState(() => _selectedPriority = val.first),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('I made this promise'),
                subtitle: Text(_iMadeThisPromise ? 'You are the promiser' : 'They promised you'),
                value: _iMadeThisPromise,
                onChanged: (val) => setState(() => _iMadeThisPromise = val),
              ),
              const SizedBox(height: 16),
              const Text('Recurrence', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<RecurrenceType>(
                initialValue: _selectedRecurrence,
                items: RecurrenceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRecurrence = val!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
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

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPersonId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a person')),
        );
        return;
      }

      final promise = widget.promise ?? Promise()
        ..title = _titleController.text
        ..description = _descriptionController.text.isEmpty ? null : _descriptionController.text
        ..personId = _selectedPersonId!
        ..category = _selectedCategory
        ..priority = _selectedPriority
        ..dueDate = _selectedDate
        ..dueTime = _selectedTime != null
            ? DateTime(0, 0, 0, _selectedTime!.hour, _selectedTime!.minute)
            : null
        ..iMadeThisPromise = _iMadeThisPromise
        ..recurrence = _selectedRecurrence
        ..notes = _notesController.text.isEmpty ? null : _notesController.text
        ..type = _iMadeThisPromise ? PromiseType.iPromised : PromiseType.theyPromised;

      if (widget.promise != null) {
        promise.id = widget.promise!.id;
      }

      await ref.read(promiseRepositoryProvider).savePromise(promise);
      if (mounted) context.pop();
    }
  }
}
