import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../money/presentation/money_screen.dart';
import '../../borrow/presentation/borrow_screen.dart';

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    return Scaffold(
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          MoneyScreen(),
          BorrowScreen(),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
