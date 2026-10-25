import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../services/ai_service.dart';
import '../widgets/widgets.dart';

/// AiAssistantScreen — AI travel assistant for Sri Lanka.
/// Opened via the raised yellow center FAB on the bottom navigation bar.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;
  String? _answer;
  List<dynamic> _suggestions = [];

  final List<String> _quickPrompts = const [
    'Best beaches to visit in August',
    'Cultural temples near Kandy',
    'Adventure activities in Ella',
    'Where to see wildlife in Sri Lanka',
    'Best scenic train routes',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _askAi(String question) async {
    final query = question.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _answer = null;
      _suggestions = [];
    });

    // Calls existing AiService
    final result = await AiService.getTravelSuggestions(query);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _suggestions = result['suggestions'] as List? ?? [];
        if (_suggestions.isEmpty) {
          _answer = 'Here are travel insights for "$query". Check local conditions before your journey!';
        }
      } else {
        _answer = result['error']?.toString() ?? 'Unable to reach AI assistant. Please try again.';
      }
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'Lanka Guide AI',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EyebrowLabel(
                      text: 'TRAVEL ASSISTANT',
                      icon: Icons.auto_awesome_rounded,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    RichText(
                      text: const TextSpan(
                        style: AppTypography.headline,
                        children: [
                          TextSpan(text: 'Tell us the trip you’re '),
                          TextSpan(
                            text: 'dreaming of.',
                            style: AppTypography.highlightPhrase,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Describe a season, a mood or an activity. We check places our local community has added first, then ask Google Gemini to fill the gaps.',
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick suggestion pills
                    const Text(
                      'TRY ASKING',
                      style: AppTypography.eyebrow,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _quickPrompts.map((prompt) {
                        return InkWell(
                          onTap: () {
                            _questionController.text = prompt;
                            _askAi(prompt);
                          },
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    prompt,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Loading State
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: AppSpacing.md),
                              Text(
                                'Asking Lanka Guide AI...',
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Answer or Suggestions
                    if (_answer != null)
                      AppCard(
                        hasGlow: true,
                        child: Text(
                          _answer!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),

                    if (_suggestions.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      ..._suggestions.map((s) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            child: Text(
                              s.toString(),
                              style: AppTypography.body.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            // Input Bar at bottom
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                border: Border(
                  top: BorderSide(color: AppColors.cardBorder, width: 1),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: TextField(
                          controller: _questionController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Best places to visit in August...',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _askAi,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => _askAi(_questionController.text),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
