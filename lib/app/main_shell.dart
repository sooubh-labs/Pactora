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
      extendBody: true, // Allows background to flow behind nav bar
      body: child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  isSelected: currentIndex == 0,
                  onTap: () => _onItemTapped(0, context),
                ),
                _NavBarItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
                  isSelected: currentIndex == 1,
                  onTap: () => _onItemTapped(1, context),
                ),
                _NavBarItem(
                  icon: Icons.add_rounded,
                  activeIcon: Icons.add_rounded,
                  isSelected: false,
                  iconSize: 28,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const QuickAddSheet(),
                    );
                  },
                ),
                _NavBarItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  isSelected: currentIndex == 3,
                  onTap: () => _onItemTapped(3, context),
                ),
                _NavBarItem(
                  icon: Icons.grid_view_rounded, // or more_horiz
                  activeIcon: Icons.grid_view_rounded,
                  isSelected: currentIndex == 4,
                  onTap: () => _onItemTapped(4, context),
                ),
              ],
            ),
          ),
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

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: iconSize,
          color: isSelected ? Colors.white : AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}
