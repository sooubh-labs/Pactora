import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../money/presentation/money_screen.dart';
import '../../borrow/presentation/borrow_screen.dart';
import '../../../shared/widgets/horizontal_calendar.dart';
import '../../money/presentation/money_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../../core/theme/app_colors.dart';

class FinancesScreen extends StatefulWidget {
  final int initialIndex;
  const FinancesScreen({super.key, this.initialIndex = 0});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  late int _currentIndex;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/timeline'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTopToggle(),
            const SizedBox(height: 16),
            Consumer(builder: (context, ref, _) {
              final moneyAsync = ref.watch(allMoneyRecordsProvider);
              final itemsAsync = ref.watch(allItemsProvider);
              final activeDates = <DateTime>[
                ...moneyAsync.value?.where((r) => r.dueDate != null).map((r) => r.dueDate!) ?? [],
                ...itemsAsync.value?.where((i) => i.expectedReturn != null).map((i) => i.expectedReturn!) ?? [],
              ];
              return HorizontalCalendar(
                activeDates: activeDates,
                initialDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _selectedDate == null 
                    ? 'All Records' 
                    : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: _currentIndex == 0 
                  ? MoneyScreen(selectedDate: _selectedDate)
                  : BorrowScreen(selectedDate: _selectedDate),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex == 0) {
            context.push('/money/add');
          } else {
            context.push('/borrow/add');
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildTopToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: Theme.of(context).brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _currentIndex == 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      'Money',
                      style: TextStyle(
                        color: _currentIndex == 0
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: _currentIndex == 1
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      'Borrow',
                      style: TextStyle(
                        color: _currentIndex == 1
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
