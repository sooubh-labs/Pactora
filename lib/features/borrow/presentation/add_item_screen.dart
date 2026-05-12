import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/item_model.dart';
import '../../people/domain/person_model.dart';
import 'item_provider.dart';
import '../../promises/presentation/widgets/person_picker_field.dart';
import '../../../shared/widgets/proof_upload_widget.dart';
import '../../../core/theme/app_colors.dart';

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
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _notesController = TextEditingController(text: widget.item?.notes);

    if (widget.item != null) {
      _selectedPersonId = widget.item!.personId;
      _iLent = widget.item!.iLent;
      _selectedDate = widget.item!.expectedReturn;
      _photoPath = widget.item!.photoPath;
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 140.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Item Name',
                controller: _nameController,
                icon: Icons.inventory_2_rounded,
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Status',
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton<bool>(
                    style: SegmentedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    segments: const [
                      ButtonSegment(value: true, label: Text('I Lent')),
                      ButtonSegment(value: false, label: Text('I Borrowed')),
                    ],
                    selected: {_iLent},
                    onSelectionChanged: (val) => setState(() => _iLent = val.first),
                  ),
                ),
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
                label: 'Expected Return Date',
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
              const SizedBox(height: 24),
              _buildField(
                label: 'Notes',
                controller: _notesController,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text('Attachment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              ProofUploadWidget(
                initialPaths: _photoPath != null ? [_photoPath!] : [],
                onPathsChanged: (paths) {
                  setState(() => _photoPath = paths.isNotEmpty ? paths.first : null);
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Item'),
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
        ..photoPath = _photoPath
        ..notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.item != null) {
        item.id = widget.item!.id;
      }

      await ref.read(itemRepositoryProvider).saveItem(item);
      if (mounted) context.pop();
    }
  }
}
