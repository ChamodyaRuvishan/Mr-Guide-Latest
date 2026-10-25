import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// StatusPill — Pill-shaped status indicator widget used for "Live trip"
/// (Soft blue background, pulsating green status dot, navigation icon, and label).
class StatusPill extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLive;
  final IconData icon;

  const StatusPill({
    super.key,
    this.label = 'Live trip',
    this.onTap,
    this.isLive = true,
    this.icon = Icons.navigation_rounded,
  });

  @override
  State<StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondaryBlueBg,
        borderRadius: AppRadius.pillBorder,
        border: Border.all(color: AppColors.secondaryBlueBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppRadius.pillBorder,
          splashColor: AppColors.secondaryBlue.withValues(alpha: 0.25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing green dot
                if (widget.isLive)
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 7.5,
                        height: 7.5,
                        decoration: BoxDecoration(
                          color: AppColors.statusGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.statusGreen.withValues(
                                alpha: _glowAnimation.value * 0.7,
                              ),
                              blurRadius: 6 * _glowAnimation.value,
                              spreadRadius: 1.5 * _glowAnimation.value,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: 7.5,
                    height: 7.5,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  widget.icon,
                  size: 13,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
