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
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkButton : AppColors.lightButton,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
              icon: Icons.home_outlined,
              selected: currentIndex == 0,
              onTap: () => onTap(0),
              isDark: isDark,
            ),
            _NavBarIcon(
              icon: Icons.add_box_outlined,
              selected: currentIndex == 1,
              onTap: () => onTap(1),
              isDark: isDark,
            ),
            _NavBarIcon(
              icon: Icons.settings_outlined,
              selected: currentIndex == 2,
              onTap: () => onTap(2),
              isDark: isDark,
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
  final bool isDark;
  const _NavBarIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: selected
            ? (isDark ? AppColors.darkButtonText : AppColors.lightButtonText)
            : (isDark
                  ? AppColors.darkButtonText.withOpacity(0.5)
                  : AppColors.lightButtonText.withOpacity(0.5)),
        size: 28,
      ),
      onPressed: onTap,
      splashRadius: 28,
    );
  }
}
