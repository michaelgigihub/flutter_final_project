import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../brand_config.dart';
import '../widgets/stitched_container.dart';
import '../widgets/button_stitch.dart';
import '../widgets/app_text_field.dart';
import 'login.dart';
import 'pin_input.dart';
import '../widgets/falling_leaves.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onNextTap() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty) {
      _showError('Please enter a username 🐼');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter your email 🐼');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email 🐼');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinInputPage(
            email: email,
            username: username,
            isCreateMode: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again 🐼');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: BrandTypography.bodyMd.copyWith(color: BrandColors.neutral),
        ),
        backgroundColor: BrandColors.natureGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height + MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8E6),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/grass_footer.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          const FallingLeavesWidget(
            fadeOutFraction: 0.35,
            leafCount: 12,
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      height: 180,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: -30,
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/panda_write.gif',
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            left: 130,
                            top: 0,
                            right: 0,
                            child: CustomPaint(
                              painter: _SpeechBubblePainter(
                                fillColor: Colors.white,
                                borderColor: BrandColors.natureGreen,
                                borderWidth: 2,
                                radius: 20,
                                tailWidth: 14,
                                tailHeight: 10,
                                tailPosition: 30,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Imagine a safe, soft place for all your thoughts. Let\'s make it real together with ',
                                            style: BrandTypography.bodyMd.copyWith(
                                              color: BrandColors.secondary.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'PanDiary',
                                            style: BrandTypography.headlineMd.copyWith(
                                              color: BrandColors.natureGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '!',
                                            style: BrandTypography.bodyMd.copyWith(
                                              color: BrandColors.secondary.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 448),
                        child: StitchedContainer(
                          padding: const EdgeInsets.all(24),
                          backgroundColor: BrandColors.neutral,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -36, 
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Transform.rotate(
                                    angle: 2 * math.pi / 180,
                                    child: Container(
                                      width: 64,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: BrandColors.primary.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                          color: BrandColors.natureGreen.withValues(alpha: 0.3),
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      'Choose a Username',
                                      style: BrandTypography.labelMd.copyWith(
                                        color: BrandColors.natureGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    hintText: 'e.g. BambooLover99',
                                    icon: Icons.face,
                                    controller: _usernameController,
                                  ),
                                  const SizedBox(height: 20),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      'Email',
                                      style: BrandTypography.labelMd.copyWith(
                                        color: BrandColors.natureGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    hintText: 'e.g. panda@bamboo.com',
                                    icon: Icons.email_outlined,
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: double.infinity,
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: BrandColors.natureGreen,
                                            ),
                                          )
                                        : ButtonStitch(
                                            label: 'Next',
                                            isSelected: true,
                                            onTap: _onNextTap,
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'I already have an account',
                        style: BrandTypography.labelMd.copyWith(
                          color: BrandColors.secondary.withValues(alpha: 0.8),
                          decoration: TextDecoration.underline,
                          decorationColor: BrandColors.primary,
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _SpeechBubblePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final double tailWidth;
  final double tailHeight;
  final double tailPosition;

  _SpeechBubblePainter({
    required this.fillColor,
    required this.borderColor,
    this.borderWidth = 2,
    this.radius = 20,
    this.tailWidth = 14,
    this.tailHeight = 10,
    this.tailPosition = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;

    final tailTop = tailPosition - tailWidth / 2;
    final tailBottom = tailPosition + tailWidth / 2;

    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    path.lineTo(r, h);
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    path.lineTo(0, tailBottom);
    path.lineTo(-tailHeight, tailPosition);
    path.lineTo(0, tailTop);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.close();

    canvas.drawShadow(path, borderColor.withValues(alpha: 0.15), 6, false);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
