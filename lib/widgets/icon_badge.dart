import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum IconBadgeShape {
  roundedSquare,
  circle,
}

/// IconBadge — Tinted rounded icon container with border and soft background tint.
/// Defaults to brand yellow at ~14% opacity with yellow outline icon.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final IconBadgeShape shape;
  final double borderRadius;

  const IconBadge({
    super.key,
    required this.icon,
    this.size = 44.0,
    this.iconSize,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.shape = IconBadgeShape.roundedSquare,
    this.borderRadius = AppRadius.md,
  });

  /// Factory for compact size (~36x36)
  const IconBadge.compact({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.shape = IconBadgeShape.roundedSquare,
    this.borderRadius = AppRadius.sm + 2,
  })  : size = 36.0,
        iconSize = 18.0;

  /// Factory for large size (~52x52)
  const IconBadge.large({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.shape = IconBadgeShape.roundedSquare,
    this.borderRadius = AppRadius.lg,
  })  : size = 52.0,
        iconSize = 26.0;

  /// Factory for blue secondary tint
  const IconBadge.blue({
    super.key,
    required this.icon,
    this.size = 44.0,
    this.iconSize,
    this.shape = IconBadgeShape.roundedSquare,
    this.borderRadius = AppRadius.md,
  })  : backgroundColor = AppColors.iconBadgeBlueBg,
        borderColor = AppColors.iconBadgeBlueBorder,
        iconColor = AppColors.iconBadgeBlueColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.iconBadgeBg;
    final effectiveBorder = borderColor ?? AppColors.iconBadgeBorder;
    final effectiveIconColor = iconColor ?? AppColors.iconBadgeColor;
    final effectiveIconSize = iconSize ?? (size * 0.5);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBg,
        shape: shape == IconBadgeShape.circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == IconBadgeShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: effectiveIconSize,
        color: effectiveIconColor,
      ),
    );
  }
}
