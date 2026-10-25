import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/widgets.dart';

/// ExploreTabScreen — Tab 1 in the bottom nav bar.
/// Mirrors the web app's Explore dropdown tools:
/// - Map search
/// - Shortest route
/// - Trip planner
/// - Authentic Sri Lanka
class ExploreTabScreen extends StatelessWidget {
  final bool isTab;

  const ExploreTabScreen({super.key, this.isTab = false});

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isTab
          ? null
          : AppBar(
              backgroundColor: AppColors.cardSurface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text('Explore Sri Lanka'),
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
              const EyebrowLabel(
                text: 'EVERYTHING FOR THE JOURNEY',
                icon: Icons.explore_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Explore Sri Lanka',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Search any place, order stops for the quickest trip, build itineraries, and discover authentic local spots.',
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 1. Map Search
              FeatureCard(
                icon: Icons.map_outlined,
                title: 'Map search',
                description:
                    'Find any place and get directions by car, bike or on foot.',
                onTap: () => Navigator.pushNamed(context, '/search'),
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Shortest Route
              FeatureCard(
                icon: Icons.route_outlined,
                title: 'Shortest route',
                description:
                    'Order your stops for the quickest trip around the island.',
                onTap: () => Navigator.pushNamed(context, '/search', arguments: 'Colombo'),
              ),
              const SizedBox(height: AppSpacing.md),

              // 3. Trip Planner
              FeatureCard(
                icon: Icons.calendar_today_outlined,
                title: 'Trip planner',
                description:
                    'Build a day-by-day itinerary with AI help and weather forecasts.',
                onTap: () => Navigator.pushNamed(context, '/ai-assistant'),
              ),
              const SizedBox(height: AppSpacing.md),

              // 4. Authentic Sri Lanka
              FeatureCard(
                icon: Icons.verified_user_outlined,
                title: 'Authentic Sri Lanka',
                description:
                    'Local tips and places from people who live here.',
                onTap: () => Navigator.pushNamed(context, '/find-places'),
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. Mobile Apps / Status
              FeatureCard(
                icon: Icons.phone_android_rounded,
                title: 'Mobile apps',
                description:
                    'Explore on Android & iOS with offline maps and instant navigation.',
                badgeText: 'Active',
                onTap: () {},
              ),

              // Safe bottom padding for floating bottom bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
