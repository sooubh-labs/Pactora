import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pactora/shared/widgets/horizontal_calendar.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('HorizontalCalendar renders week and selects day', (WidgetTester tester) async {
    DateTime? selected;
    final today = DateTime.now();
    final activeDates = [today];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HorizontalCalendar(
          activeDates: activeDates,
          onDateSelected: (date) => selected = date,
        ),
      ),
    ));

    expect(find.text(DateFormat('d').format(today)), findsWidgets);
    
    // Tap today
    await tester.tap(find.text(DateFormat('d').format(today)).first);
    await tester.pumpAndSettle();
    
    expect(selected?.year, today.year);
    expect(selected?.month, today.month);
    expect(selected?.day, today.day);
  });
}
