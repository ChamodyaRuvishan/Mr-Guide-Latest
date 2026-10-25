import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// BrandLogo — Mr. Guide brand logo widget:
/// Yellow compass/location pin icon + "Mr." (italic yellow serif) + "Guide" (white serif).
class BrandLogo extends StatelessWidget {
  final double fontSize;
  final double iconSize;
  final bool showTagline;
  final VoidCallback? onTap;

  const BrandLogo({
    super.key,
    this.fontSize = 22.0,
    this.iconSize = 24.0,
    this.showTagline = false,
    this.onTap,
  });

  const BrandLogo.large({
    super.key,
    this.showTagline = true,
    this.onTap,
  })  : fontSize = 34.0,
        iconSize = 36.0;

  const BrandLogo.compact({
    super.key,
    this.showTagline = false,
    this.onTap,
  })  : fontSize = 19.0,
        iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final logoWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand compass / map icon badge
        Container(
          padding: EdgeInsets.all(iconSize * 0.22),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.explore_rounded,
            size: iconSize * 0.65,
            color: AppColors.onPrimary,
          ),
        ),
        SizedBox(width: iconSize * 0.35),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamilyFallback: AppTypography.serifFallbacks,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                children: const [
                  TextSpan(
                    text: 'Mr. ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text: 'Guide',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                'Sri Lanka, guided by locals',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: fontSize * 0.4,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ],
    );

    if (onTap == null) {
      return logoWidget;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: logoWidget,
      ),
    );
  }
}
