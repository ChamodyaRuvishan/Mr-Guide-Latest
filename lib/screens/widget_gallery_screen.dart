import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/widgets.dart';

/// WidgetGalleryScreen — Debug-only gallery screen demonstrating all design tokens
/// and reusable UI widgets for Step 1 verification.
class WidgetGalleryScreen extends StatelessWidget {
  const WidgetGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Widget Gallery (Debug)'),
        backgroundColor: AppColors.cardSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BRAND LOGO & AVATARS
              const SectionHeader(
                eyebrow: 'BRAND ASSETS',
                title: 'Logos & User Avatars',
                subtext: 'Adapts to Mr. Guide yellow + dark navy identity.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  BrandLogo(),
                  BrandLogo.compact(),
                  BrandAvatar(username: 'Praneeth', showBadge: true),
                  BrandAvatar(username: 'Chamodya'),
                  BrandAvatar(username: 'Traveler'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const BrandLogo.large(),
              const SizedBox(height: AppSpacing.xxl),

              // 2. STATUS PILL
              const SectionHeader(
                eyebrow: 'LIVE TRIP STATUS',
                title: 'Status Pill Indicator',
                subtext: 'Pulsing green dot with soft blue container.',
              ),
              Wrap(
                spacing: AppSpacing.md,
                children: [
                  StatusPill(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Live trip tapped')),
                      );
                    },
                  ),
                  const StatusPill(
                    isLive: false,
                    label: 'Trip completed',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 3. TYPOGRAPHY SCALE
              const SectionHeader(
                eyebrow: 'TYPOGRAPHY SCALE',
                title: 'Serif Display & Clean Sans',
                highlightPhrase: 'highlighted phrases',
                subtext: 'Elegant serif display with italic yellow accents.',
              ),
              const Text(
                'Find the island the locals know.',
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: const TextSpan(
                  style: AppTypography.headline,
                  children: [
                    TextSpan(text: 'Explore '),
                    TextSpan(
                      text: 'Sri Lanka',
                      style: AppTypography.highlightPhrase,
                    ),
                    TextSpan(text: ' with us'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Popular places to begin your journey',
                  style: AppTypography.title),
              const SizedBox(height: AppSpacing.xs),
              const Text('Component title in geometric sans-serif',
                  style: AppTypography.titleSans),
              const SizedBox(height: AppSpacing.xs),
              const Text('Lead subtitle for sections and heroes.',
                  style: AppTypography.subtitle),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                  'Regular body text in muted blue-grey for long readable descriptions.',
                  style: AppTypography.body),
              const SizedBox(height: AppSpacing.xs),
              const Text('Caption text for timestamps, tags, and small notes.',
                  style: AppTypography.caption),
              const SizedBox(height: AppSpacing.xxl),

              // 4. ICON BADGES
              const SectionHeader(
                eyebrow: 'ICON CONTAINERS',
                title: 'Tinted Icon Badges',
                subtext: 'Yellow and blue soft tints with outline icons.',
              ),
              const Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  IconBadge(icon: Icons.map_outlined),
                  IconBadge(
                    icon: Icons.route_outlined,
                    shape: IconBadgeShape.circle,
                  ),
                  IconBadge.compact(icon: Icons.calendar_today_outlined),
                  IconBadge.large(icon: Icons.explore_outlined),
                  IconBadge.blue(icon: Icons.navigation_rounded),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 5. PILL BUTTONS
              const SectionHeader(
                eyebrow: 'BUTTON VARIANTS',
                title: 'Pill Buttons & CTAs',
                subtext: 'Primary filled, secondary outlined, and glassy.',
              ),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  PillButton(
                    label: 'Explore local tips',
                    trailingIcon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  ),
                  PillButton.secondary(
                    label: 'Become a guide',
                    onPressed: () {},
                  ),
                  PillButton.glassy(
                    label: 'Start planning',
                    onPressed: () {},
                  ),
                  PillButton(
                    label: 'Small',
                    size: PillButtonSize.small,
                    onPressed: () {},
                  ),
                  PillButton(
                    label: 'Large CTA',
                    size: PillButtonSize.large,
                    leadingIcon: Icons.auto_awesome,
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PillButton(
                label: 'Full Width Action',
                fullWidth: true,
                trailingIcon: Icons.arrow_forward_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 6. APP CARDS & PRESS FEEDBACK
              const SectionHeader(
                eyebrow: 'CONTAINERS',
                title: 'AppCard with Press Feedback',
                subtext: 'Tap card to see smooth 0.97 scale and ripple.',
              ),
              AppCard(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('AppCard pressed!')),
                  );
                },
                hasGlow: true,
                child: const Row(
                  children: [
                    IconBadge(icon: Icons.touch_app_outlined),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Interactive Card Container',
                              style: AppTypography.titleSans),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                              'Includes card border, soft shadow, glow and tap animation.',
                              style: AppTypography.body),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 7. FEATURE CARDS (FULL WIDTH & COMPACT)
              const SectionHeader(
                eyebrow: 'FEATURE CARDS',
                title: 'Explore & Journey Tools',
                subtext: 'Full-width and 2-column compact layouts.',
                onViewAll: null,
              ),
              FeatureCard(
                icon: Icons.map_outlined,
                title: 'Map search',
                description: 'Search any place, compare results and get turn-by-turn directions.',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              FeatureCard(
                icon: Icons.route_outlined,
                title: 'Shortest route',
                description: 'Order your stops for the quickest trip around the island.',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              FeatureCard(
                icon: Icons.phone_android_rounded,
                title: 'Mobile apps',
                description: 'Android and iOS apps are on the way.',
                badgeText: 'Coming soon',
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.lg),
              // Compact 2-column grid demo
              Row(
                children: [
                  Expanded(
                    child: FeatureCard.compact(
                      icon: Icons.account_balance_outlined,
                      title: 'Sigiriya',
                      description: 'Cultural Triangle',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FeatureCard.compact(
                      icon: Icons.temple_buddhist_outlined,
                      title: 'Temple of Tooth',
                      description: 'Kandy hill capital',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
