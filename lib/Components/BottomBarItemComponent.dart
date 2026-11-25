import 'package:flutter/material.dart';

class BottomBarItemComponent {
  static BottomNavigationBarItem create({
    required IconData icon,
    required String label,
    IconData? activeIcon,
    int badgeCount = 0,
  }) {
    Widget iconWidget = Icon(icon);
    Widget activeIconWidget = Icon(activeIcon ?? icon);

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text('$badgeCount'),
        child: iconWidget,
      );
      activeIconWidget = Badge(
        label: Text('$badgeCount'),
        child: activeIconWidget,
      );
    }

    return BottomNavigationBarItem(
      icon: iconWidget,
      activeIcon: activeIconWidget,
      label: label,
    );
  }
}
