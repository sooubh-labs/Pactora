import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';

class HorizontalCalendar extends StatefulWidget {
  final List<DateTime> activeDates;
  final ValueChanged<DateTime?> onDateSelected;
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
  DateTime? _selectedDate;
  late ScrollController _scrollController;
  final List<DateTime> _dates = [];
  late Set<String> _normalizedActiveDates;

  static const int _daysBefore = 30;
  static const int _daysAfter = 90;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate != null ? _normalize(widget.initialDate!) : null;
    _generateDates();
    _updateNormalizedDates();
    
    // Initial scroll position to the selected date or today
    final targetDate = _selectedDate ?? _normalize(DateTime.now());
    final initialIndex = _dates.indexWhere((d) => isSameDay(d, targetDate));
    _scrollController = ScrollController(
      initialScrollOffset: initialIndex >= 0 ? (initialIndex * 76.0) - 20 : 0,
    );
  }

  @override
  void didUpdateWidget(HorizontalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeDates != oldWidget.activeDates) {
      _updateNormalizedDates();
    }
    if (widget.initialDate != oldWidget.initialDate) {
      setState(() {
        _selectedDate = widget.initialDate != null ? _normalize(widget.initialDate!) : null;
      });
      _scrollToSelectedOrToday();
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

  void _scrollToSelectedOrToday() {
    final targetDate = _selectedDate ?? _normalize(DateTime.now());
    final index = _dates.indexWhere((d) => isSameDay(d, targetDate));
    if (index >= 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        (index * 76.0) - 150, // Center it roughly
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Reduced from 120
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = _selectedDate != null && isSameDay(date, _selectedDate!);
          final hasActivity = _hasActivity(date);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDate = null;
                  } else {
                    _selectedDate = _normalize(date);
                  }
                });
                widget.onDateSelected(_selectedDate);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56, // Reduced from 64
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24), // More rounded pill
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.04),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10, // Smaller font
                        letterSpacing: 0.5,
                        color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d').format(date),
                      style: TextStyle(
                        fontSize: 18, // Smaller font
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
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
