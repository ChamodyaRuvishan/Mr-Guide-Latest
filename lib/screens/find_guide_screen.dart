import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/guide_service.dart';
import '../widgets/widgets.dart';
import 'guide_register_screen.dart';

/// FindGuideScreen — Tab 2 in bottom nav bar and accessible at '/guides'.
/// Displays verified local guides, transparent pricing steps, and guide registration.
class FindGuideScreen extends StatefulWidget {
  final bool isTab;

  const FindGuideScreen({super.key, this.isTab = false});

  @override
  State<FindGuideScreen> createState() => _FindGuideScreenState();
}

class _FindGuideScreenState extends State<FindGuideScreen> {
  bool _isLoading = true;
  List<dynamic> _guides = [];

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() => _isLoading = true);
    // Uses existing GuideService
    final guides = await GuideService.getAllGuides();
    if (!mounted) return;
    setState(() {
      _guides = guides;
      _isLoading = false;
    });
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: AppColors.cardSurface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text('Find a Guide'),
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
                text: 'LOCAL GUIDES',
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Travel with someone who knows the way.',
                style: AppTypography.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Every guide sets transparent, distance-based prices. See the estimate before booking, follow live, and pay at the end.',
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action buttons: Become a guide CTA
              Row(
                children: [
                  Expanded(
                    child: PillButton.secondary(
                      label: 'Become a guide',
                      leadingIcon: Icons.badge_outlined,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuideRegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // How it works steps
              const Text(
                'HOW MR. GUIDE WORKS',
                style: AppTypography.eyebrow,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildStepCard(
                step: '1',
                title: 'Choose your guide',
                description:
                    'Compare languages, regions, ratings, and price per kilometre.',
                icon: Icons.person_search_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildStepCard(
                step: '2',
                title: 'Track the trip live',
                description:
                    'See your guide’s position and trip status in real time.',
                icon: Icons.navigation_outlined,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildStepCard(
                step: '3',
                title: 'Pay at the end',
                description:
                    'The final fare is calculated from the real distance. Pay by card or QR code.',
                icon: Icons.qr_code_rounded,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Guides List
              const Text(
                'VERIFIED GUIDES',
                style: AppTypography.eyebrow,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_guides.isEmpty)
                AppCard(
                  child: Column(
                    children: [
                      const IconBadge(icon: Icons.people_outline_rounded),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Verified Local Guides Coming Online',
                        style: AppTypography.titleSans,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Our community of verified local guides across Colombo, Kandy, Galle, and Ella is actively expanding.',
                        style: AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PillButton(
                        label: 'Register as a Guide',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GuideRegisterScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              else
                ..._guides.map((guide) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: FeatureCard(
                      icon: Icons.person_pin_circle_outlined,
                      title: guide['name']?.toString() ?? 'Local Guide',
                      description:
                          '${guide['regions'] ?? 'Sri Lanka'} • ${guide['languages'] ?? 'English'}',
                      onTap: () {},
                    ),
                  );
                }),

              // Safe bottom padding for floating bottom bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String step,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamilyFallback: AppTypography.serifFallbacks,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(title, style: AppTypography.titleSans.copyWith(fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
