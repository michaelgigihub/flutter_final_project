import 'package:flutter/material.dart';
import 'brand_config.dart';
import 'widgets/stitched_container.dart';
import 'widgets/emotion_button.dart';
import 'widgets/falling_leaves.dart';

class MoodSelectorPage extends StatefulWidget {
  final String? initialMood;
  final List<String>? initialEmotions;

  const MoodSelectorPage({super.key, this.initialMood, this.initialEmotions});

  @override
  State<MoodSelectorPage> createState() => _MoodSelectorPageState();
}

class _MoodSelectorPageState extends State<MoodSelectorPage> {
  double _moodValue = 2.0;
  final Set<String> _selectedEmotions = {'Happy'};

  String get _moodAsset {
    if (_moodValue == 1.0) {
      return 'assets/images/moods/Rough.png';
    }
    if (_moodValue == 3.0) {
      return 'assets/images/moods/Amazing.png';
    }
    return 'assets/images/moods/Neutral.png';
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMood == 'Rough') {
      _moodValue = 1.0;
    } else if (widget.initialMood == 'Amazing') {
      _moodValue = 3.0;
    } else {
      _moodValue = 2.0;
    }

    if (widget.initialEmotions != null && widget.initialEmotions!.isNotEmpty) {
      _selectedEmotions
        ..clear()
        ..addAll(widget.initialEmotions!);
    }
  }

  final List<String> _emotions = [
    'Happy',
    'Joyful',
    'Peaceful',
    'Tired',
    'Sad',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8E6),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/grass_footer.png',
              fit: BoxFit.cover,
            ),
          ),
          const FallingLeavesWidget(
            fadeOutFraction: 0.35,
            leafCount: 12,
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 56,
                bottom: 120,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'How are you feeling?',
                    style: BrandTypography.headlineMd.copyWith(
                      color: BrandColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Move the slider to show your mood.',
                    style: BrandTypography.bodyMd.copyWith(
                      color: BrandColors.secondary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Central Panda Avatar
                  SizedBox(
                    width: 224,
                    height: 224,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: BrandColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Avatar Container
                        Container(
                          width: 224,
                          height: 224,
                          decoration: BoxDecoration(
                            color: BrandColors.neutral,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: BrandColors.primary.withValues(
                                  alpha: 0.4,
                                ),
                                offset: const Offset(0, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            foregroundPainter: DashedBorderPainter(
                              color: BrandColors.primary,
                              strokeWidth: 4,
                              dashWidth: 10,
                              gap: 6,
                              borderRadius: 112,
                            ),
                            child: ClipOval(
                              child: Transform.scale(
                                scale: 1.1,
                                child: Image.asset(
                                  _moodAsset,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _moodValue == 1.0
                        ? 'Rough'
                        : _moodValue == 2.0
                        ? 'Neutral'
                        : 'Amazing',
                    style: BrandTypography.headlineMd.copyWith(
                      color: BrandColors.natureGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mood Scale Slider Area
                  Container(
                    decoration: BoxDecoration(
                      color: BrandColors.neutral,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: BrandColors.primary.withValues(alpha: 0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      foregroundPainter: DashedBorderPainter(
                        color: BrandColors.primary,
                        strokeWidth: 2,
                        dashWidth: 8,
                        gap: 6,
                        borderRadius: 32,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: BrandColors.natureGreen
                                    .withValues(alpha: 0.7),
                                inactiveTrackColor: BrandColors.primary
                                    .withValues(alpha: 0.4),
                                trackHeight: 12.0,
                                thumbColor: BrandColors.neutral,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 18.0,
                                  elevation: 4,
                                ),
                                overlayColor: BrandColors.primary.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: Slider(
                                value: _moodValue,
                                min: 1,
                                max: 3,
                                divisions: 2,
                                onChanged: (value) {
                                  setState(() {
                                    _moodValue = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rough',
                                  style: BrandTypography.labelMd.copyWith(
                                    color: BrandColors.natureGreen.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Amazing',
                                  style: BrandTypography.labelMd.copyWith(
                                    color: BrandColors.natureGreen.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Emotion Tags Grid
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "What's making you feel this way?",
                      style: BrandTypography.labelMd.copyWith(
                        color: BrandColors.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._emotions.map((emotion) {
                        final isSelected = _selectedEmotions.contains(emotion);
                        return ButtonStitch(
                          label: emotion,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedEmotions.remove(emotion);
                              } else {
                                _selectedEmotions.add(emotion);
                              }
                            });
                          },
                        );
                      }),
                      // Custom Button
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7E5E4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: CustomPaint(
                            foregroundPainter: DashedBorderPainter(
                              color: const Color(0xFFD6D3D1),
                              strokeWidth: 2,
                              dashWidth: 8,
                              gap: 6,
                              borderRadius: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: BrandColors.natureGreen,
                size: 28,
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          final moodLabel = _moodValue == 1.0
              ? 'Rough'
              : _moodValue == 2.0
              ? 'Neutral'
              : 'Amazing';
          Navigator.of(
            context,
          ).pop({'mood': moodLabel, 'emotions': _selectedEmotions.toList()});
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: BrandColors.natureGreen,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BrandColors.natureGreen.withValues(alpha: 0.3),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: CustomPaint(
            foregroundPainter: DashedBorderPainter(
              color: BrandColors.primary,
              strokeWidth: 2,
              gap: 6,
              dashWidth: 8,
              borderRadius: 16,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: BrandColors.neutral,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save Mood',
                    style: BrandTypography.labelMd.copyWith(
                      color: BrandColors.neutral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBottomBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gap;

  DashedBottomBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
