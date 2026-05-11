import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../money/presentation/money_screen.dart';
import '../../borrow/presentation/borrow_screen.dart';
import '../../../shared/widgets/horizontal_calendar.dart';
import '../../money/presentation/money_provider.dart';
import '../../borrow/presentation/item_provider.dart';

class FinancesScreen extends StatefulWidget {
  final int initialIndex;
  const FinancesScreen({super.key, this.initialIndex = 0});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finances'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Money'),
              Tab(text: 'Borrow'),
            ],
          ),
        ),
        body: Column(
          children: [
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TabBar(
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    tabs: _tabController.index == 0 
                      ? const [
                          Tab(text: 'All'),
                          Tab(text: 'I Owe'),
                          Tab(text: 'Owed'),
                          Tab(text: 'Paid'),
                        ]
                      : const [
                          Tab(text: 'All'),
                          Tab(text: 'Active'),
                          Tab(text: 'Overdue'),
                          Tab(text: 'Done'),
                        ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  MoneyScreen(selectedDate: _selectedDate),
                  BorrowScreen(selectedDate: _selectedDate),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_tabController.index == 0) {
              context.push('/money/add');
            } else {
              context.push('/borrow/add');
            }
          },
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }
}
