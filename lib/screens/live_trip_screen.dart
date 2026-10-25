import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/trip_service.dart';
import '../widgets/widgets.dart';

/// LiveTripScreen — Tracks real-time guide position and trip status.
/// Opened via the "Live trip" StatusPill in the HomeHeader.
class LiveTripScreen extends StatefulWidget {
  const LiveTripScreen({super.key});

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  bool _isLoading = true;
  List<dynamic> _trips = [];

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    // Calls existing TripService
    final trips = await TripService.getMyTrips();
    if (!mounted) return;
    setState(() {
      _trips = trips;
      _isLoading = false;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusPill(label: 'Live trip', isLive: true),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowLabel(
                      text: 'TRIP STATUS',
                      icon: Icons.navigation_rounded,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Live Trip Tracking',
                      style: AppTypography.headline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Follow your guide’s live location, route progress, and distance-based fare.',
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    if (_trips.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          children: [
                            const IconBadge.large(
                              icon: Icons.explore_off_outlined,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Text(
                              'No Active Trip In Progress',
                              style: AppTypography.titleSans,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'When you book a verified local guide, you will see their live GPS coordinates and estimated arrival time here.',
                              style: AppTypography.body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PillButton(
                              label: 'Find a guide',
                              trailingIcon: Icons.arrow_forward_rounded,
                              onPressed: () {
                                Navigator.pushNamed(context, '/guides');
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      ..._trips.map((trip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Trip #${trip['id'] ?? '—'}',
                                      style: AppTypography.titleSans,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.sm),
                                      ),
                                      child: Text(
                                        (trip['status'] ?? 'PENDING')
                                            .toString()
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Destination: ${trip['dest_address'] ?? 'Sri Lanka'}',
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
      ),
    );
  }
}
