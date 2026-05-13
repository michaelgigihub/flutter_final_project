import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'brand_config.dart';
import 'widgets/stitched_container.dart';
import 'widgets/falling_leaves.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: BrandColors.natureGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/panda_play.gif',
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'PanDiary',
                          style: GoogleFonts.sourGummy(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: BrandColors.natureGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your cozy journal companion',
                          style: BrandTypography.bodyMd.copyWith(
                            color: BrandColors.secondary.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 24),

                        StitchedContainer(
                          borderRadius: 20,
                          backgroundColor: BrandColors.neutral,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_rounded,
                                    color: BrandColors.natureGreen,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'App Creators',
                                    style: GoogleFonts.sourGummy(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: BrandColors.natureGreen,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildCreatorRow(
                                name: 'Michael Castillo',
                                role: 'Backend',
                                icon: Icons.storage_rounded,
                              ),
                              const SizedBox(height: 12),
                              _buildCreatorRow(
                                name: 'Cairos Magno',
                                role: 'Frontend',
                                icon: Icons.brush_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        StitchedContainer(
                          borderRadius: 20,
                          backgroundColor: BrandColors.neutral,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: BrandColors.natureGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Version 1.0',
                                style: GoogleFonts.sourGummy(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: BrandColors.secondary.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCreatorRow({
    required String name,
    required String role,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: BrandColors.primary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: BrandColors.natureGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.sourGummy(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: BrandColors.secondary,
              ),
            ),
            Text(
              role,
              style: BrandTypography.bodyMd.copyWith(
                fontSize: 13,
                color: BrandColors.secondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
