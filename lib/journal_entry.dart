import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/stitched_container.dart';
import 'brand_config.dart';

class JournalEntryPage extends StatelessWidget {
  const JournalEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.tertiary,
      body: SafeArea(
        child: CustomPaint(
          painter: PaperGridPainter(),
          child: Stack(
            children: [
              Positioned(
                top: 48,
                left: 8,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: BrandColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Positioned(
                bottom: 96,
                right: 16,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Icon(
                    Icons.spa,
                    size: 64,
                    color: BrandColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetadata(),
                          const SizedBox(height: 24),
                          Text(
                            'A perfect afternoon at the bamboo grove',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.28,
                              letterSpacing: -0.56,
                              color: const Color(0xFF292524),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPolaroid(),
                          const SizedBox(height: 16),
                          _buildJournalText(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedBorderPainter(
        color: BrandColors.primary,
        strokeWidth: 2,
        gap: 6,
        dashWidth: 8,
        borderRadius: 32,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: BrandColors.tertiary.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: BrandColors.primary.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 68, 145, 99),
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                hoverColor: BrandColors.primary.withValues(alpha: 0.5),
              ),
            ),
            Text(
              'Entry',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: const Color.fromARGB(255, 68, 145, 99),
                letterSpacing: -0.5,
              ),
            ),
            CustomPaint(
              foregroundPainter: DashedBorderPainter(
                color: BrandColors.primary,
                strokeWidth: 2,
                gap: 4,
                dashWidth: 6,
                borderRadius: 9999,
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                label: Text(
                  'Edit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 68, 145, 99),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ).copyWith(
                  shadowColor: WidgetStateProperty.all(BrandColors.primary.withValues(alpha: 0.4)),
                  elevation: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.hovered)) return 6;
                    return 4;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetadataChip(
          icon: Icons.calendar_today,
          label: 'October 24, 2023',
          backgroundColor: const Color(0xFFFFEDD5),
          textColor: const Color(0xFF9A3412),
          borderColor: const Color(0xFFFDBA74),
        ),
        _MetadataChip(
          icon: Icons.sentiment_very_satisfied,
          label: 'Cozy',
          backgroundColor: const Color(0xFFFFE4E6),
          textColor: const Color(0xFF9F1239),
          borderColor: const Color(0xFFFDA4AF),
        ),
        _MetadataChip(
          icon: Icons.wb_sunny,
          label: 'Sunny',
          backgroundColor: const Color(0xFFE0F2FE),
          textColor: const Color(0xFF075985),
          borderColor: const Color(0xFF7DD3FC),
        ),
      ],
    );
  }

  Widget _buildPolaroid() {
    return Center(
      child: Transform.rotate(
        angle: -0.05,
        child: Container(
          width: 320,
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          child: CustomPaint(
            foregroundPainter: DashedBorderPainter(
              color: BrandColors.primary,
              strokeWidth: 4,
              gap: 8,
              dashWidth: 12,
              borderRadius: 16,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.primary.withValues(alpha: 0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: BrandColors.tertiary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BrandColors.primary,
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            'assets/images/bamboo_forest.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'So peaceful...',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 18,
                          color: Color(0xFF78716C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Positioned(
                    top: -24,
                    right: -24,
                    child: Transform.rotate(
                      angle: 0.2,
                      child: CustomPaint(
                        foregroundPainter: DashedBorderPainter(
                          color: const Color(0xFFFDA4AF),
                          strokeWidth: 2,
                          gap: 4,
                          dashWidth: 6,
                          borderRadius: 24,
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE4E6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(254, 205, 211, 1),
                                offset: Offset(0, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFF43F5E),
                            size: 24,
                          ),
                        ),
                      ),
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

  Widget _buildJournalText() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: BrandColors.primary,
          strokeWidth: 2,
          gap: 6,
          dashWidth: 8,
          borderRadius: 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BrandColors.primary.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Today I found the most comfortable spot under the large oak tree near the edge of the bamboo forest. The sunlight was filtering through the leaves just right, creating dancing patterns on the ground.\n\nI brought my favorite green tea and just sat there for hours, listening to the wind rustle through the stalks. It felt like the whole world slowed down just for me.\n\nSometimes, doing absolutely nothing is exactly what you need to do.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF44403C),
                    height: 1.77,
                  ),
                ),
              ),
              const Positioned(
                bottom: 16,
                right: 16,
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    Icons.cruelty_free,
                    size: 36,
                    color: BrandColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: DashedBorderPainter(
        color: borderColor,
        strokeWidth: 2,
        gap: 4,
        dashWidth: 6,
        borderRadius: 9999,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaperGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BrandColors.primary
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
