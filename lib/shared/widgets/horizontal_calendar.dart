import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class HorizontalCalendar extends StatefulWidget {
  final List<DateTime> activeDates;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? initialDate;

  const HorizontalCalendar({
    super.key,
    required this.activeDates,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<HorizontalCalendar> createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;
  late Set<DateTime> _normalizedActiveDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _weekDates = _generateWeek(_selectedDate);
    _updateNormalizedDates();
  }

  @override
  void didUpdateWidget(HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeDates != oldWidget.activeDates) {
      _updateNormalizedDates();
    }
    if (widget.initialDate != null && widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate!;
        _weekDates = _generateWeek(_selectedDate);
      });
    }
  }

  void _updateNormalizedDates() {
    _normalizedActiveDates = widget.activeDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  List<DateTime> _generateWeek(DateTime centerDate) {
    final startOfWeek = centerDate.subtract(Duration(days: centerDate.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  bool _hasActivity(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _normalizedActiveDates.contains(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _weekDates.length,
        itemBuilder: (context, index) {
          final date = _weekDates[index];
          final isSelected = isSameDay(date, _selectedDate);
          final hasActivity = _hasActivity(date);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              widget.onDateSelected(date);
            },
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3), // Mon, Tue, etc.
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (hasActivity) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
