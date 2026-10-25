import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// AppCard — Rounded surface card container with border, soft shadow,
/// and smooth press-down scale feedback (scale to 0.97 + ripple).
class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasGlow;
  final Color? glowColor;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.card,
    this.hasGlow = false,
    this.glowColor,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = widget.backgroundColor ?? AppColors.cardSurface;
    final effectiveBorder = widget.borderColor ??
        (widget.hasGlow ? AppColors.cardBorderGlow : AppColors.cardBorder);
    final radius = BorderRadius.circular(widget.borderRadius);

    final cardContent = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.gradient == null ? effectiveBg : null,
        gradient: widget.gradient,
        borderRadius: radius,
        border: Border.all(
          color: _isPressed ? AppColors.primary : effectiveBorder,
          width: _isPressed ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          if (widget.hasGlow || _isPressed)
            BoxShadow(
              color: (widget.glowColor ?? AppColors.primary)
                  .withValues(alpha: _isPressed ? 0.25 : 0.12),
              blurRadius: 22,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap == null) {
      return cardContent;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: cardContent,
      ),
    );
  }
}
