import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../brand_config.dart';
import '../widgets/stitched_container.dart';
import '../widgets/button_stitch.dart';
import '../widgets/app_text_field.dart';
import 'login.dart';
import 'pin_input.dart';

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

    // Validate: username not empty
    if (username.isEmpty) {
      _showError('Please enter a username 🐼');
      return;
    }

    // Validate: email not empty
    if (email.isEmpty) {
      _showError('Please enter your email 🐼');
      return;
    }

    // Basic email format validation
    if (!email.contains('@') || !email.contains('.')) {
      _showError('Please enter a valid email 🐼');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;

      // Navigate to PIN input in create mode
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
    // Calculate total screen height regardless of keyboard to prevent background movement
    final screenHeight = MediaQuery.of(context).size.height + MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: BrandColors.tertiary,
      body: Stack(
        children: [
          // Blurred Circles for depth (positioned using fixed screenHeight so they don't move)
          Positioned(
            top: screenHeight * 0.15,
            left: -screenWidth * 0.2,
            child: _buildBlurredCircle(
              color: BrandColors.primary.withValues(alpha: 0.2), 
              size: 256,
            ),
          ),


          // Background Decoration (Floating Icons)
          Positioned(
            top: screenHeight * 0.08,
            left: 20,
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
            top: screenHeight * 0.15,
            right: 20,
            child: Transform.rotate(
              angle: 0.2,
              child: Icon(
                Icons.spa,
                size: 64,
                color: BrandColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.25,
            right: -20,
            child: Transform.rotate(
              angle: 0.5,
              child: Icon(
                Icons.eco,
                size: 56,
                color: BrandColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration Area
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: MediaQuery.of(context).size.height * 0.22,
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Mascot Container
                          Container(
                            decoration: BoxDecoration(
                              color: BrandColors.neutral,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: BrandColors.primary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BrandColors.natureGreen.withValues(alpha: 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  'assets/images/panda_create_account.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          // Floating Star
                          Positioned(
                            top: -10,
                            right: MediaQuery.of(context).size.width * 0.1,
                            child: Transform.rotate(
                              angle: 12 * math.pi / 180,
                              child: Icon(
                                Icons.star,
                                color: BrandColors.primary.withValues(alpha: 0.4),
                                size: 40,
                              ),
                            ),
                          ),
                          // Floating Leaf
                          Positioned(
                            bottom: -5,
                            left: MediaQuery.of(context).size.width * 0.1,
                            child: Transform.rotate(
                              angle: -12 * math.pi / 180,
                              child: Icon(
                                Icons.eco,
                                color: BrandColors.secondary.withValues(alpha: 0.4),
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Header
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Panda Journal',
                            style: BrandTypography.headlineLg.copyWith(
                              color: BrandColors.natureGreen,
                              fontSize: 28,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Let's create your cozy space.",
                            style: BrandTypography.bodyMd.copyWith(
                              color: BrandColors.secondary.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Form Container
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
                              // Decorative Tape
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

                              // Form Fields
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Username Field
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

                                  // Email Field
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

                                  // Next Button
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

                    // Already have an account
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

  Widget _buildBlurredCircle({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.5),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}
