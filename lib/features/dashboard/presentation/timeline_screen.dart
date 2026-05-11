import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../../core/constants/category_constants.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promisesAsync = ref.watch(allPromisesProvider);
    final itemsAsync = ref.watch(allItemsProvider);
    final recordsAsync = ref.watch(allMoneyRecordsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline Activity')),
      body: _buildTimeline(
        promisesAsync.value ?? [],
        itemsAsync.value ?? [],
        recordsAsync.value ?? [],
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> promises, List<dynamic> items, List<dynamic> records) {
    final allEvents = [...promises, ...items, ...records];
    
    // Sort by createdAt or dueDate? Implementation plan says activity timeline.
    // Usually means linear history. Let's sort by createdAt descending.
    allEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allEvents.isEmpty) {
      return const Center(child: Text('No activity yet'));
    }

    final groupedEvents = <String, List<dynamic>>{};
    for (final event in allEvents) {
      final date = DateFormat('MMM dd, yyyy').format(event.createdAt);
      groupedEvents.putIfAbsent(date, () => []).add(event);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEvents.keys.length,
      itemBuilder: (context, index) {
        final date = groupedEvents.keys.elementAt(index);
        final events = groupedEvents[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                date,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ...events.map((e) => _TimelineItem(event: e)),
            const Gap(16),
          ],
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final dynamic event;
  const _TimelineItem({required this.event});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.info_outline;
    Color color = Colors.grey;
    String title = '';
    String subtitle = '';
    String route = '';

    if (event.runtimeType.toString().contains('Promise')) {
      final config = CategoryConstants.categories[event.category]!;
      icon = config.icon;
      color = config.color;
      title = 'Promise: ${event.title}';
      subtitle = 'Created on ${DateFormat('hh:mm a').format(event.createdAt)}';
      route = '/promises/${event.id}';
    } else if (event.runtimeType.toString().contains('BorrowItem')) {
      icon = event.iLent ? Icons.outbox : Icons.move_to_inbox;
      color = event.iLent ? Colors.orange : Colors.blue;
      title = 'Borrow: ${event.name}';
      subtitle = event.iLent ? 'You lent this item' : 'You borrowed this item';
      route = '/borrow/${event.id}';
    } else if (event.runtimeType.toString().contains('MoneyRecord')) {
      icon = Icons.currency_rupee;
      color = event.iOwe ? Colors.red : Colors.green;
      title = 'Money: ${event.currency} ${event.amount}';
      subtitle = event.iOwe ? 'You owe this amount' : 'This amount is owed to you';
      route = '/money/${event.id}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: () => context.push(route),
      ),
    );
  }
}
