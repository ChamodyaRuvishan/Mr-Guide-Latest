import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// EyebrowLabel — Small uppercase, letter-spaced, yellow badge/label
/// (e.g. "START SOMEWHERE", "AUTHENTIC SRI LANKA", "LOCAL GUIDES").
class EyebrowLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;

  const EyebrowLabel({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.fontSize,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveFontSize = fontSize ?? 11.0;
    final effectiveSpacing = letterSpacing ?? 1.8;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: effectiveFontSize + 2,
            color: effectiveColor,
          ),
          const SizedBox(width: AppSpacing.xs + 2),
        ],
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              color: effectiveColor,
              fontSize: effectiveFontSize,
              letterSpacing: effectiveSpacing,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
