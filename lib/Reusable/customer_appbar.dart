import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleWidget; // 👈 dynamic title
  final double height;
  final Color backgroundColor;
  final Widget? leadingIcon;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.titleWidget,
    this.height = 60,
    this.backgroundColor = Colors.black,
    this.leadingIcon,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 4,
      leading: leadingIcon,
      title: titleWidget ?? const SizedBox(), // 👈 use passed widget or empty
      centerTitle: true,
      actions: actions,
    );
  }
}
