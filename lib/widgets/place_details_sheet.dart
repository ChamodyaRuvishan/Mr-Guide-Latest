import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/place.dart';
import '../services/auth_service.dart';
import '../services/place_service.dart';
import 'pill_button.dart';

/// PlaceDetailsSheet — Bottom sheet modal mirroring the web app's PlaceDetailsPanel.
/// Shows place details, live community reviews, review submission form,
/// verified authentic local tips, and directions/trip actions.
class PlaceDetailsSheet extends StatefulWidget {
  final Place place;
  final String? distanceKm;
  final VoidCallback onGetDirections;
  final VoidCallback onToggleTrip;
  final bool isInTrip;

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    this.distanceKm,
    required this.onGetDirections,
    required this.onToggleTrip,
    this.isInTrip = false,
  });

  static Future<void> show(
    BuildContext context, {
    required Place place,
    String? distanceKm,
    required VoidCallback onGetDirections,
    required VoidCallback onToggleTrip,
    bool isInTrip = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
      ),
      builder: (_) => PlaceDetailsSheet(
        place: place,
        distanceKm: distanceKm,
        onGetDirections: onGetDirections,
        onToggleTrip: onToggleTrip,
        isInTrip: isInTrip,
      ),
    );
  }

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _reviews = [];
  double _avgRating = 0.0;
  int _totalReviews = 0;

  List<dynamic> _authenticUsers = [];
  List<dynamic> _authenticBusinesses = [];

  int _selectedStar = 5;
  bool _isSubmitting = false;
  String? _submitError;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuth();
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() => _isLoggedIn = user != null);
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    final placeId = widget.place.googlePlaceId ?? widget.place.id;

    final results = await Future.wait([
      PlaceService.getPlaceReviews(placeId),
      PlaceService.getAuthenticDetails(
        placeIdOrGoogleId: placeId,
        name: widget.place.name,
        lat: widget.place.lat,
        lng: widget.place.lng,
      ),
    ]);

    if (!mounted) return;

    final reviewData = results[0];
    final authenticData = results[1];

    setState(() {
      _reviews = reviewData['reviews'] as List? ?? [];
      _avgRating = (reviewData['avgRating'] as num?)?.toDouble() ??
          widget.place.rating ??
          0.0;
      _totalReviews = (reviewData['totalCount'] as num?)?.toInt() ??
          widget.place.userRatingsTotal ??
          _reviews.length;

      _authenticUsers = authenticData['users'] as List? ?? [];
      _authenticBusinesses = authenticData['businesses'] as List? ?? [];
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      setState(() => _submitError = 'Please write a brief comment');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final placeId = widget.place.googlePlaceId ?? widget.place.id;
    final result = await PlaceService.submitReview(
      placeIdOrGoogleId: placeId,
      rating: _selectedStar,
      comment: comment,
      placeName: widget.place.name,
      placeAddress: widget.place.address,
      lat: widget.place.lat,
      lng: widget.place.lng,
      category: widget.place.type,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      _fetchData();
    } else {
      setState(() {
        _submitError = result['error']?.toString() ?? 'Failed to submit review';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Place Header Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.place.name,
                          style: AppTypography.headline.copyWith(fontSize: 22),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (widget.place.type.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            widget.place.type.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (_avgRating > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          _avgRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($_totalReviews)',
                          style: AppTypography.caption,
                        ),
                      ],
                      if (widget.distanceKm != null) ...[
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.near_me_rounded,
                            size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.distanceKm} km',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.place.address.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.place.address,
                      style: AppTypography.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Primary action buttons: Directions & Add to Trip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: 'Directions',
                      leadingIcon: Icons.directions_rounded,
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onGetDirections();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PillButton.secondary(
                      label: widget.isInTrip ? 'In Trip' : 'Add to Trip',
                      leadingIcon:
                          widget.isInTrip ? Icons.check_rounded : Icons.add_rounded,
                      onPressed: () {
                        widget.onToggleTrip();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Tab bar: Reviews vs Authentic Local Tips
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Community Reviews'),
                Tab(text: 'Authentic Sri Lanka'),
              ],
            ),

            // Tab Views
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildReviewsTab(),
                        _buildAuthenticTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        // Write a review card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leave a Review',
                style: AppTypography.titleSans,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Interactive Star Rating
              Row(
                children: List.generate(5, (index) {
                  final starVal = index + 1;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      starVal <= _selectedStar
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                    onPressed: () => setState(() => _selectedStar = starVal),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _commentController,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: _isLoggedIn
                      ? 'Share your experience with travelers...'
                      : 'Please login to submit a review',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              if (_submitError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _submitError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: PillButton(
                  label: _isLoggedIn ? 'Post Review' : 'Login to Review',
                  size: PillButtonSize.small,
                  isLoading: _isSubmitting,
                  onPressed: () {
                    if (!_isLoggedIn) {
                      Navigator.pushNamed(context, '/login').then((_) => _checkAuth());
                    } else {
                      _submitReview();
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Reviews list
        if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'No reviews yet for this place.\nBe the first to share your experience!',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ..._reviews.map((r) {
            final reviewer = r['User']?['username'] ?? r['username'] ?? 'Traveler';
            final comment = r['comment'] ?? '';
            final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.cardBorderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        reviewer.toString(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      comment.toString(),
                      style: AppTypography.body,
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAuthenticTab() {
    if (_authenticUsers.isEmpty && _authenticBusinesses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Authentic Sri Lanka Tips',
                style: AppTypography.titleSans,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Verified local experts share prices, timings, and hidden gems not found in guidebooks.',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (_authenticUsers.isNotEmpty) ...[
          const Text(
            'VERIFIED LOCAL ADVISORS',
            style: AppTypography.eyebrow,
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._authenticUsers.map((u) {
            final name = u['User']?['username'] ?? u['title'] ?? 'Local Expert';
            final desc = u['description'] ?? u['advice'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name.toString(), style: AppTypography.titleSans),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(desc.toString(), style: AppTypography.body),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        if (_authenticBusinesses.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text(
            'VERIFIED LOCAL BUSINESSES',
            style: AppTypography.eyebrow,
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._authenticBusinesses.map((b) {
            final name = b['business_name'] ?? b['name'] ?? 'Local Business';
            final type = b['business_type'] ?? '';
            final desc = b['description'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name.toString(), style: AppTypography.titleSans),
                      if (type.isNotEmpty)
                        Text(
                          type.toString().toUpperCase(),
                          style: AppTypography.eyebrow.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(desc.toString(), style: AppTypography.body),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
