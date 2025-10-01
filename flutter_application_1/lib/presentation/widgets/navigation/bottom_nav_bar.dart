import 'package:flutter/material.dart';

/// Bottom navigation bar widget (Single Responsibility)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                color: const Color(0xFF007AFF),
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.trending_up_rounded,
                label: 'Trends',
                isActive: currentIndex == 1,
                color: const Color(0xFF34C759),
                onTap: () => onTap(1),
              ),
              _NavBarItem(
                icon: Icons.add_circle,
                label: 'Add',
                isActive: currentIndex == 2,
                color: const Color(0xFFFF9500),
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Recipes',
                isActive: currentIndex == 3,
                color: const Color(0xFFFF3B30),
                onTap: () => onTap(3),
              ),
              _NavBarItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 4,
                color: const Color(0xFF5856D6),
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? color : const Color(0xFF8E8E93),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? color : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
