import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../domain/money_model.dart';
import '../../people/domain/person_model.dart';
import 'money_provider.dart';
import '../../promises/presentation/widgets/person_picker_field.dart';
import '../../../shared/widgets/proof_upload_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.record?.amount.toString());
    _descriptionController = TextEditingController(text: widget.record?.description);

    if (widget.record != null) {
      _selectedPersonId = widget.record!.personId;
      _iOwe = widget.record!.iOwe;
      _selectedDate = widget.record!.dueDate;
      _selectedCurrency = widget.record!.currency;
    }
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
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  prefixText: '$_selectedCurrency ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('I Owe')),
                  ButtonSegment(value: false, label: Text('They Owe Me')),
                ],
                selected: {_iOwe},
                onSelectionChanged: (val) => setState(() => _iOwe = val.first),
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ProofUploadWidget(
                onUpload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload coming soon')),
                  );
                },
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

      final record = widget.record ?? MoneyRecord()
        ..amount = double.parse(_amountController.text)
        ..currency = _selectedCurrency
        ..personId = _selectedPersonId!
        ..iOwe = _iOwe
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
