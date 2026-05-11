import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          selectedIndex: currentIndex > 4 ? 0 : currentIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuickAddSheet(),
              );
              return;
            }
            _onItemTapped(index, context);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 24), 
              selectedIcon: Icon(Icons.dashboard_rounded, size: 24, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.handshake_outlined, size: 24), 
              selectedIcon: Icon(Icons.handshake_rounded, size: 24, color: AppColors.primary),
              label: 'Promises',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline, size: 32), 
              selectedIcon: Icon(Icons.add_circle_rounded, size: 32, color: AppColors.primary),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 24), 
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, size: 24, color: AppColors.primary),
              label: 'Finances',
            ),
            NavigationDestination(
              icon: Icon(Icons.more_horiz_outlined, size: 24), 
              selectedIcon: Icon(Icons.more_horiz_rounded, size: 24, color: AppColors.primary),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) {
      return 0;
    }
    if (location.startsWith('/promises')) {
      return 1;
    }
    if (location.startsWith('/finances') ||
        location.startsWith('/money') ||
        location.startsWith('/borrow')) {
      return 3;
    }
    if (location.startsWith('/more') || 
        location.startsWith('/people') ||
        location.startsWith('/calendar') ||
        location.startsWith('/timeline') ||
        location.startsWith('/stats') ||
        location.startsWith('/archive') ||
        location.startsWith('/settings') ||
        location.startsWith('/profile')) {
      return 4;
    }
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
        context.go('/more');
        break;
    }
  }
}
