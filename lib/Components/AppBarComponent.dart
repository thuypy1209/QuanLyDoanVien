import 'package:flutter/material.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const AppBarComponent({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
    this.backgroundColor = const Color(0xFF0D47A1),
    this.foregroundColor = Colors.white,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  // Constructor phụ tương thích nếu truyền vị trí
  const AppBarComponent.fromTitle(
    this.title, {
    super.key,
    this.actions,
    this.showBack = true,
    this.leading,
    this.backgroundColor = const Color(0xFF0D47A1),
    this.foregroundColor = Colors.white,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      elevation: elevation,
      automaticallyImplyLeading: showBack && leading == null,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
