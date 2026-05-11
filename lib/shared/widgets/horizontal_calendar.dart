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
  late ScrollController _scrollController;
  final List<DateTime> _dates = [];
  late Set<String> _normalizedActiveDates;

  static const int _daysBefore = 30;
  static const int _daysAfter = 90;

  @override
  void initState() {
    super.initState();
    _selectedDate = _normalize(widget.initialDate ?? DateTime.now());
    _generateDates();
    _updateNormalizedDates();
    
    // Initial scroll position to the selected date
    final initialIndex = _dates.indexWhere((d) => isSameDay(d, _selectedDate));
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex >= 0 ? (initialIndex * 68.0) - 20 : 0,
    );
  }

  @override
  void didUpdateWidget(HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeDates != oldWidget.activeDates) {
      _updateNormalizedDates();
    }
    if (widget.initialDate != null && !isSameDay(widget.initialDate, _selectedDate)) {
      setState(() {
        _selectedDate = _normalize(widget.initialDate!);
      });
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateDates() {
    final now = DateTime.now();
    for (int i = -_daysBefore; i <= _daysAfter; i++) {
      _dates.add(now.add(Duration(days: i)));
    }
  }

  void _updateNormalizedDates() {
    _normalizedActiveDates = widget.activeDates
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toSet();
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _hasActivity(DateTime date) {
    return _normalizedActiveDates.contains(DateFormat('yyyy-MM-dd').format(date));
  }

  void _scrollToSelected() {
    final index = _dates.indexWhere((d) => isSameDay(d, _selectedDate));
    if (index >= 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        (index * 68.0) - 150, // Center it roughly
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = isSameDay(date, _selectedDate);
          final hasActivity = _hasActivity(date);
          final isToday = isSameDay(date, DateTime.now());

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDate = _normalize(date));
                widget.onDateSelected(_selectedDate);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (isToday ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hasActivity)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
