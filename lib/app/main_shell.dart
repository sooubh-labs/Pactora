import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(location),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Promises'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Borrow'),
          NavigationDestination(icon: Icon(Icons.currency_rupee), label: 'Money'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'People'),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/promises')) return 2;
    if (location.startsWith('/borrow')) return 3;
    if (location.startsWith('/money')) return 4;
    if (location.startsWith('/people')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/calendar');
        break;
      case 2:
        context.go('/promises');
        break;
      case 3:
        context.go('/borrow');
        break;
      case 4:
        context.go('/money');
        break;
      case 5:
        context.go('/people');
        break;
    }
  }
}
