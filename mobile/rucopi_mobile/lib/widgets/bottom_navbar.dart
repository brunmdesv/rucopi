import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: theme.brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
              icon: Icons.home_outlined,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavBarIcon(
              icon: Icons.add_box_outlined,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavBarIcon(
              icon: Icons.settings_outlined,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _NavBarIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(
        icon,
        color: selected
            ? theme.colorScheme.primary
            : theme.iconTheme.color?.withOpacity(0.6) ?? Colors.grey,
        size: 28,
      ),
      onPressed: onTap,
      splashRadius: 28,
    );
  }
}
