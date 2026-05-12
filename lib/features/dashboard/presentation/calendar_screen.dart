import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final promisesAsync = ref.watch(allPromisesProvider);
    final itemsAsync = ref.watch(allItemsProvider);
    final recordsAsync = ref.watch(allMoneyRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            eventLoader: (day) {
              final promises = promisesAsync.value ?? [];
              final items = itemsAsync.value ?? [];
              final records = recordsAsync.value ?? [];

              final events = <dynamic>[];
              events.addAll(promises.where((p) => isSameDay(p.dueDate, day)));
              events.addAll(items.where((i) => isSameDay(i.expectedReturn, day)));
              events.addAll(records.where((r) => isSameDay(r.dueDate, day)));
              return events;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _buildDayEvents(_selectedDay!),
          ),
        ],
      ),
    );
  }

  Widget _buildDayEvents(DateTime day) {
    final promisesAsync = ref.watch(allPromisesProvider);
    final itemsAsync = ref.watch(allItemsProvider);
    final recordsAsync = ref.watch(allMoneyRecordsProvider);

    final promises = promisesAsync.value?.where((p) => isSameDay(p.dueDate, day)).toList() ?? [];
    final items = itemsAsync.value?.where((i) => isSameDay(i.expectedReturn, day)).toList() ?? [];
    final records = recordsAsync.value?.where((r) => isSameDay(r.dueDate, day)).toList() ?? [];

    if (promises.isEmpty && items.isEmpty && records.isEmpty) {
      return const Center(child: Text('No commitments due today'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (promises.isNotEmpty) ...[
          const Text('PROMISES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ...promises.map((p) => ListTile(
                title: Text(p.title),
                leading: const Icon(Icons.handshake_outlined),
                onTap: () => context.push('/promises/${p.id}'),
              )),
        ],
        if (items.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('BORROWED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ...items.map((i) => ListTile(
                title: Text(i.name),
                leading: const Icon(Icons.swap_horiz),
                onTap: () => context.push('/borrow/${i.id}'),
              )),
        ],
        if (records.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('MONEY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          ...records.map((r) => ListTile(
                title: Text('${r.currency} ${r.amount}'),
                leading: const Icon(Icons.payments_outlined),
                onTap: () => context.push('/money/${r.id}'),
              )),
        ],
      ],
    );
  }
}
