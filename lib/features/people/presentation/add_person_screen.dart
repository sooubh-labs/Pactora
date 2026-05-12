import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/person_model.dart';
import 'person_provider.dart';
import '../../../core/theme/app_colors.dart';

class AddPersonScreen extends ConsumerStatefulWidget {
  final Person? person;

  const AddPersonScreen({super.key, this.person});

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person?.name);
    _phoneController = TextEditingController(text: widget.person?.phone);
    _notesController = TextEditingController(text: widget.person?.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 140.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildField(
                label: 'Name',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildField(
                label: 'Notes',
                controller: _notesController,
                icon: Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Person'),
                ),
              ),
              const SizedBox(height: 24),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? (maxLines * 16.0) - 24 : 0), // Adjust icon position for multiline
                child: Icon(icon, color: AppColors.primary.withOpacity(0.5)),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final person = widget.person ?? Person()
        ..name = _nameController.text
        ..phone = _phoneController.text.isEmpty ? null : _phoneController.text
        ..notes = _notesController.text.isEmpty ? null : _notesController.text;

      if (widget.person != null) {
        person.id = widget.person!.id;
      }

      await ref.read(personRepositoryProvider).savePerson(person);
      if (mounted) context.pop();
    }
  }
}
