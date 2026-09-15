import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../constants/category_icon_catalog.dart';

/// Reusable Category Icon Widget supporting modern HugeIcons with fallback.
class CategoryIcon extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final iconData = CategoryIconCatalog.getIconData(iconName);

    return HugeIcon(
      icon: iconData,
      color: effectiveColor,
      size: size,
    );
  }
}
