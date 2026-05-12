import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/money_model.dart';
import '../../people/domain/person_model.dart';
import 'money_provider.dart';
import '../../promises/presentation/widgets/person_picker_field.dart';
import '../../../shared/widgets/proof_upload_widget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/user_preferences_provider.dart';

class AddMoneyRecordScreen extends ConsumerStatefulWidget {
  final MoneyRecord? record;

  const AddMoneyRecordScreen({super.key, this.record});

  @override
  ConsumerState<AddMoneyRecordScreen> createState() => _AddMoneyRecordScreenState();
}

class _AddMoneyRecordScreenState extends ConsumerState<AddMoneyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  int? _selectedPersonId;
  bool _iOwe = true;
  DateTime? _selectedDate;
  String _selectedCurrency = 'INR';
  String _selectedCurrencySymbol = '₹';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.record?.amount.toString());
    _descriptionController = TextEditingController(text: widget.record?.description);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(userPreferencesProvider);
      if (widget.record != null) {
        _selectedPersonId = widget.record!.personId;
        _iOwe = widget.record!.iOwe;
        _selectedDate = widget.record!.dueDate;
        _selectedCurrency = widget.record!.currency;
        final currencyOpt = currencyOptions.firstWhere(
          (opt) => opt.code == _selectedCurrency,
          orElse: () => currencyOptions.first,
        );
        _selectedCurrencySymbol = currencyOpt.symbol;
        _photoPath = widget.record!.photoPath;
      } else {
        _selectedCurrency = prefs.currencyCode;
        _selectedCurrencySymbol = prefs.currencySymbol;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'New Money Record' : 'Edit Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 140.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Amount',
                controller: _amountController,
                icon: Icons.payments_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                prefixText: '$_selectedCurrencySymbol  ',
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Currency',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<CurrencyOption>(
                      isExpanded: true,
                      value: currencyOptions.firstWhere(
                        (opt) => opt.code == _selectedCurrency,
                        orElse: () => currencyOptions.first,
                      ),
                      items: currencyOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text('${opt.symbol} ${opt.code} (${opt.name})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCurrency = val.code;
                            _selectedCurrencySymbol = val.symbol;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildWrapper(
                label: 'Record Type',
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
                      ButtonSegment(value: true, label: Text('I Owe')),
                      ButtonSegment(value: false, label: Text('They Owe Me')),
                    ],
                    selected: {_iOwe},
                    onSelectionChanged: (val) => setState(() => _iOwe = val.first),
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
              const SizedBox(height: 24),
              _buildField(
                label: 'Description',
                controller: _descriptionController,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text('Proof of Transfer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
                  child: const Text('Save Record'),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return _buildWrapper(
      label: label,
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
          prefixText: prefixText,
          prefixStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
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

      final record = widget.record ?? MoneyRecord()
        ..amount = double.parse(_amountController.text)
        ..currency = _selectedCurrency
        ..personId = _selectedPersonId!
        ..iOwe = _iOwe
        ..photoPath = _photoPath
        ..dueDate = _selectedDate
        ..description = _descriptionController.text.isEmpty ? null : _descriptionController.text;

      if (widget.record != null) {
        record.id = widget.record!.id;
      }

      await ref.read(moneyRepositoryProvider).saveRecord(record);
      if (mounted) context.pop();
    }
  }
}
