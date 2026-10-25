import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'eyebrow_label.dart';

/// SectionHeader — Consistent header layout with:
/// 1. Optional Eyebrow label (small yellow uppercase text)
/// 2. Elegant Serif title (with optional highlighted phrase in italic yellow)
/// 3. Optional "View all" action link with chevron
/// 4. Optional secondary subtext description
class SectionHeader extends StatelessWidget {
  final String? eyebrow;
  final IconData? eyebrowIcon;
  final String title;
  final String? highlightPhrase;
  final String? subtext;
  final VoidCallback? onViewAll;
  final String viewAllText;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    this.eyebrow,
    this.eyebrowIcon,
    required this.title,
    this.highlightPhrase,
    this.subtext,
    this.onViewAll,
    this.viewAllText = 'View all',
    this.padding = const EdgeInsets.only(bottom: AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow
          if (eyebrow != null && eyebrow!.isNotEmpty) ...[
            EyebrowLabel(text: eyebrow!, icon: eyebrowIcon),
            const SizedBox(height: AppSpacing.xs + 2),
          ],

          // Title row with optional "View all" link
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTypography.headline,
                    children: [
                      TextSpan(text: title),
                      if (highlightPhrase != null &&
                          highlightPhrase!.isNotEmpty) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: highlightPhrase,
                          style: AppTypography.highlightPhrase,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (onViewAll != null) ...[
                const SizedBox(width: AppSpacing.md),
                InkWell(
                  onTap: onViewAll,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewAllText,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Subtext description
          if (subtext != null && subtext!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              subtext!,
              style: AppTypography.subtitle,
            ),
          ],
        ],
      ),
    );
  }
}
