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
import '../../../shared/widgets/proof_upload_widget.dart';
import '../../../core/theme/app_colors.dart';

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 140.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Title',
                controller: _titleController,
                icon: Icons.title_rounded,
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              const Text('Who is involved?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              PersonPickerField(
                selectedPersonId: _selectedPersonId,
                onPersonSelected: (Person person) {
                  setState(() => _selectedPersonId = person.id);
                },
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Promise Type',
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: const Text('I made this promise', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
                  subtitle: Text(_iMadeThisPromise ? 'You are the promiser' : 'They promised you', style: const TextStyle(color: AppColors.textSecondary)),
                  value: _iMadeThisPromise,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _iMadeThisPromise = val),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              CategoryChipSelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (PromiseCategory category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildWrapper(
                      label: 'Due Date',
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, color: AppColors.primary.withOpacity(0.5), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedDate == null ? AppColors.textTertiary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWrapper(
                      label: 'Time (Optional)',
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: AppColors.primary.withOpacity(0.5), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedTime == null ? AppColors.textTertiary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Priority',
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton<Priority>(
                    style: SegmentedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    segments: const [
                      ButtonSegment(value: Priority.low, label: Text('Low')),
                      ButtonSegment(value: Priority.medium, label: Text('Medium')),
                      ButtonSegment(value: Priority.high, label: Text('High')),
                    ],
                    selected: {_selectedPriority},
                    onSelectionChanged: (val) => setState(() => _selectedPriority = val.first),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Recurrence',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RecurrenceType>(
                    value: _selectedRecurrence,
                    icon: Icon(Icons.expand_more_rounded, color: AppColors.primary.withOpacity(0.5)),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    items: RecurrenceType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRecurrence = val!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Notes / Description',
                controller: _notesController,
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              const Text('Attachment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              ProofUploadWidget(
                onUpload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload coming soon')),
                  );
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Promise'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return _buildWrapper(
      label: label,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 16.0) - 24 : 0),
            child: Icon(icon, color: AppColors.primary.withOpacity(0.5)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: child,
        ),
      ],
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
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
