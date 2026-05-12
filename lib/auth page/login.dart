import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../widgets/stitched_container.dart';
import '../widgets/button_stitch.dart';
import '../widgets/app_text_field.dart';
import '../brand_config.dart';
import 'create_account.dart';
import 'pin_input.dart';
import '../journal_list.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/falling_leaves.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoginLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onLoginTap() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('Please enter your email 🐼');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email 🐼');
      return;
    }

    setState(() => _isLoginLoading = true);

    try {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinInputPage(email: email, isCreateMode: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again 🐼');
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _onGoogleLoginTap() async {
    setState(() => _isGoogleLoading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (!mounted) return;
        _showError('Google sign-in was cancelled.');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google Login successful!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JournalListsPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Google login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
    final screenHeight =
        MediaQuery.of(context).size.height +
        MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8E6),
      body: Stack(
        children: [
          // Grass footer at bottom
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
          // Falling leaves effect
          const FallingLeavesWidget(
            fadeOutFraction: 0.35,
            leafCount: 12,
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      height: 180,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Panda on the left
                          Positioned(
                            left: -20,
                            bottom: 0,
                            child: Image.asset(
                              'assets/images/panda_wave.gif',
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Speech bubble (single seamless shape)
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
                                            text: 'Welcome back to ',
                                            style: BrandTypography.bodyMd.copyWith(
                                              color: BrandColors.secondary.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'PanDiary',
                                            style: BrandTypography.bodyMd.copyWith(
                                              color: BrandColors.natureGreen,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '! Ready to drift back into your cozy stream of thoughts?',
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
                                    angle: 2 * 3.14159 / 180,
                                    child: Container(
                                      width: 64,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: BrandColors.primary.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                          color: BrandColors.natureGreen
                                              .withValues(alpha: 0.3),
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
                                  _buildLabel('Email'),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    hintText: 'Enter your email',
                                    icon: Icons.email_outlined,
                                    controller: _emailController,
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isLoginLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: BrandColors.natureGreen,
                                            ),
                                          )
                                        : ButtonStitch(
                                            label: 'Login',
                                            trailingIcon: Icons.login,
                                            isSelected: true,
                                            onTap: _onLoginTap,
                                          ),
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isGoogleLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: BrandColors.natureGreen,
                                            ),
                                          )
                                        : ButtonStitch(
                                            label: 'Login with Google',
                                            trailingIcon: Icons.account_circle_outlined,
                                            isSelected: true,
                                            onTap: _onGoogleLoginTap,
                                          ),
                                  ),
                                  const SizedBox(height: 35),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ButtonStitch(
                                      label: 'Create Account',
                                      isSelected: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateAccountPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: BrandTypography.labelMd.copyWith(color: BrandColors.natureGreen),
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
  final double tailPosition; // vertical position of tail tip on left side

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

    // Tail attaches on the left edge, centered at tailPosition
    final tailTop = tailPosition - tailWidth / 2;
    final tailBottom = tailPosition + tailWidth / 2;

    final path = Path();

    // Start at top-left corner (after radius)
    path.moveTo(r, 0);
    // Top edge
    path.lineTo(w - r, 0);
    // Top-right corner
    path.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    // Right edge
    path.lineTo(w, h - r);
    // Bottom-right corner
    path.arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
    // Bottom edge
    path.lineTo(r, h);
    // Bottom-left corner
    path.arcToPoint(Offset(0, h - r), radius: Radius.circular(r));
    // Left edge down to tail bottom
    path.lineTo(0, tailBottom);
    // Tail point (goes left, towards the panda)
    path.lineTo(-tailHeight, tailPosition);
    // Tail back to left edge top
    path.lineTo(0, tailTop);
    // Left edge up to top-left corner
    path.lineTo(0, r);
    // Top-left corner
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.close();

    // Draw shadow
    canvas.drawShadow(path, borderColor.withValues(alpha: 0.15), 6, false);

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border
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
