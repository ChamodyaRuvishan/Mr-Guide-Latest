import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum PillButtonVariant {
  primary, // Yellow filled, dark navy text
  secondary, // Outlined border, transparent bg
  glassy, // Frosted glass with subtle white background & border
}

enum PillButtonSize {
  small, // height ~36
  medium, // height ~46
  large, // height ~54
}

/// PillButton — Fully rounded pill button with primary (yellow),
/// secondary (outlined), and glassy variants.
class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final PillButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool fullWidth;
  final bool isLoading;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.primary,
    this.size = PillButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  const PillButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PillButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
  }) : variant = PillButtonVariant.secondary;

  const PillButton.glassy({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = PillButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
  }) : variant = PillButtonVariant.glassy;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final (height, horizontalPadding, fontSize, iconSize) = switch (widget.size) {
      PillButtonSize.small => (36.0, 14.0, 13.0, 16.0),
      PillButtonSize.medium => (46.0, 20.0, 14.5, 18.0),
      PillButtonSize.large => (54.0, 26.0, 16.0, 20.0),
    };

    final (bgColor, textColor, border) = switch (widget.variant) {
      PillButtonVariant.primary => (
          AppColors.primary,
          AppColors.onPrimary,
          Border.all(color: Colors.transparent, width: 0),
        ),
      PillButtonVariant.secondary => (
          Colors.transparent,
          AppColors.textPrimary,
          Border.all(color: AppColors.cardBorderSubtle, width: 1.2),
        ),
      PillButtonVariant.glassy => (
          Colors.white.withValues(alpha: 0.12),
          AppColors.textPrimary,
          Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.0),
        ),
    };

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, size: iconSize, color: textColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(widget.trailingIcon, size: iconSize, color: textColor),
          ],
        ],
      ],
    );

    final buttonBox = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.pillBorder,
        border: border,
        boxShadow: widget.variant == PillButtonVariant.primary
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.pillBorder,
          onTap: widget.isLoading ? null : widget.onPressed,
          splashColor: widget.variant == PillButtonVariant.primary
              ? Colors.black.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.15),
          child: Center(child: content),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.fullWidth
              ? SizedBox(width: double.infinity, child: buttonBox)
              : buttonBox,
        ),
      ),
    );
  }
}
