import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/quick_add_sheet.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex > 4 ? 0 : currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const QuickAddSheet(),
            );
            return;
          }
          _onItemTapped(index, context);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Promises'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finances'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'People'),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/promises')) return 1;
    if (location.startsWith('/finances')) return 3;
    if (location.startsWith('/people')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/promises');
        break;
      case 3:
        context.go('/finances');
        break;
      case 4:
        context.go('/people');
        break;
    }
  }
}