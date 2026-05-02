import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../widgets/stitched_container.dart';
import '../widgets/button_stitch.dart';
import '../widgets/app_text_field.dart';
import '../brand_config.dart';
import '../services/auth_service.dart';
import 'create_account.dart';
import 'pin_input.dart';
import 'auth_mode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _onLoginTap() async {
    final username = _usernameController.text.trim();

    // Validate: not empty
    if (username.isEmpty) {
      _showError('Please enter a username 🐼');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate: user exists
      final exists = await _authService.usernameExists(username);
      if (!mounted) return;

      if (!exists) {
        _showError('No panda found with that name 🐼');
        return;
      }

      // Navigate to PIN input in login mode
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PinInputPage(
            username: username,
            mode: AuthMode.login,
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
              color: BrandColors.primary.withValues(alpha: 0.2), // Lower intensity
              size: 256,
            ),
          ),
          Positioned(
            top: screenHeight * 0.90, // Lower position
            right: -screenWidth * 0.2,
            child: _buildBlurredCircle(
              color: BrandColors.primary.withValues(alpha: 0.2), // Lower intensity
              size: 288,
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
                    // Illustration
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: MediaQuery.of(context).size.height * 0.22,
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Image.asset(
                        'assets/images/panda_login.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Header
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Text(
                            'Panda Journal',
                            style: BrandTypography.headlineLg.copyWith(
                              color: BrandColors.natureGreen,
                              fontSize: 32, // Slightly larger for login page
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your cozy digital sanctuary.',
                            style: BrandTypography.bodyMd.copyWith(
                              color: BrandColors.secondary.withValues(alpha: 0.7),
                            ),
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
                                    angle: 2 * 3.14159 / 180, // 2 degrees
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
                                  _buildLabel('Username'),
                                  const SizedBox(height: 8),
                                  AppTextField(
                                    hintText: 'Enter your cozy name',
                                    icon: Icons.person_outline,
                                    controller: _usernameController,
                                  ),
                                  const SizedBox(height: 32),

                                  // Login Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isLoading
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
                                  const SizedBox(height: 16),

                                  // Create Account Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ButtonStitch(
                                      label: 'Create Account',
                                      isSelected: false,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CreateAccountPage(),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        text,
        style: BrandTypography.labelMd.copyWith(
          color: BrandColors.natureGreen,
        ),
      ),
    );
  }
}
