import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../domain/person_model.dart';
import 'person_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/image_service.dart';

class AddPersonScreen extends ConsumerStatefulWidget {
  final Person? person;

  const AddPersonScreen({super.key, this.person});

  @override
  ConsumerState<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends ConsumerState<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person?.name);
    _emailController = TextEditingController(text: widget.person?.email);
    _phoneController = TextEditingController(text: widget.person?.phone);
    _notesController = TextEditingController(text: widget.person?.notes);
    _avatarPath = widget.person?.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await ImagePickerService.pickImage(source);
      if (image != null) {
        setState(() => _avatarPath = image.path);
      }
    }
  }

  Future<void> _importFromVcf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['vcf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      // Simple VCF Parser
      String? name;
      String? phone;
      String? email;
      String? photoBase64;

      final fnMatch = RegExp(r'FN:(.*)', multiLine: true).firstMatch(content);
      if (fnMatch != null) {
        name = fnMatch.group(1)?.trim();
      } else {
        final nMatch = RegExp(r'N:(.*)', multiLine: true).firstMatch(content);
        if (nMatch != null) {
          name = nMatch.group(1)?.replaceAll(';', ' ').trim();
        }
      }

      final telMatch = RegExp(r'TEL;?.*:(.*)', multiLine: true).firstMatch(content);
      if (telMatch != null) {
        phone = telMatch.group(1)?.trim();
      }

      final emailMatch = RegExp(r'EMAIL;?.*:(.*)', multiLine: true).firstMatch(content);
      if (emailMatch != null) {
        email = emailMatch.group(1)?.trim();
      }

      // Handle Base64 Photo
      final photoMatch = RegExp(r'PHOTO;.*BASE64:(.*)', multiLine: true, dotAll: true).firstMatch(content) ??
                         RegExp(r'PHOTO;.*ENCODING=b:(.*)', multiLine: true, dotAll: true).firstMatch(content);

      if (photoMatch != null) {
        // Find end of base64 block (next VCard field starts with uppercase letters followed by :)
        String raw = photoMatch.group(1)!;
        int nextField = raw.indexOf(RegExp(r'\n[A-Z]'));
        if (nextField != -1) {
          photoBase64 = raw.substring(0, nextField).replaceAll(RegExp(r'\s+'), '');
        } else {
          photoBase64 = raw.replaceAll(RegExp(r'\s+'), '');
        }
      }

      if (photoBase64 != null) {
        try {
          final bytes = base64Decode(photoBase64);
          final appDocDir = await getApplicationDocumentsDirectory();
          final fileName = 'vcf_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final savedFile = await File('${appDocDir.path}/$fileName').writeAsBytes(bytes);
          _avatarPath = savedFile.path;
        } catch (e) {
          debugPrint('Error decoding VCF photo: $e');
        }
      }

      if (name != null || phone != null || email != null) {
        setState(() {
          if (name != null) _nameController.text = name;
          if (phone != null) _phoneController.text = phone;
          if (email != null) _emailController.text = email;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact details imported')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find contact details in file')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_page_outlined),
            tooltip: 'Import from VCF',
            onPressed: _importFromVcf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 140.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                        child: _avatarPath == null
                            ? const Icon(Icons.person_add_alt_1_rounded, size: 40, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                label: 'Email Address',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
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
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      // Check for duplicates
      final people = await ref.read(personRepositoryProvider).getAllPeople();
      final duplicate = people.where((p) {
        if (widget.person != null && p.id == widget.person!.id) return false;

        final nameMatch = p.name.toLowerCase() == name.toLowerCase();
        
        String cleanPhone(String? p) => p?.replaceAll(RegExp(r'[\s\-\(\)]'), '') ?? '';
        final cleanInputPhone = cleanPhone(phone);
        final phoneMatch = cleanInputPhone.isNotEmpty && cleanPhone(p.phone) == cleanInputPhone;

        return nameMatch || phoneMatch;
      }).firstOrNull;

      if (duplicate != null && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Duplicate Contact'),
            content: Text(
              'A person with the same ${duplicate.name.toLowerCase() == name.toLowerCase() ? 'name' : 'phone number'} already exists (${duplicate.name}). Do you want to save anyway?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save Anyway'),
              ),
            ],
          ),
        );
        if (proceed != true) return;
      }

      final person = widget.person ?? Person()
        ..name = name
        ..email = _emailController.text.isEmpty ? null : _emailController.text.trim()
        ..phone = phone.isEmpty ? null : phone
        ..avatarPath = _avatarPath
        ..notes = _notesController.text.isEmpty ? null : _notesController.text.trim();

      if (widget.person != null) {
        person.id = widget.person!.id;
      }

      final id = await ref.read(personRepositoryProvider).savePerson(person);
      if (mounted) context.pop(id);
    }
  }
}
