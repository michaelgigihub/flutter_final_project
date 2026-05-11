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
      backgroundColor: BrandColors.tertiary,
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.15,
            left: -screenWidth * 0.2,
            child: _buildBlurredCircle(
              color: BrandColors.primary.withValues(alpha: 0.2),
              size: 256,
            ),
          ),
          Positioned(
            top: screenHeight * 0.90,
            right: -screenWidth * 0.2,
            child: _buildBlurredCircle(
              color: BrandColors.primary.withValues(alpha: 0.2),
              size: 288,
            ),
          ),
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
                      margin: const EdgeInsets.only(bottom: 24),
                      height: MediaQuery.of(context).size.height * 0.22,
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Image.asset(
                        'assets/images/panda_login.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Text(
                            'Panda Journal',
                            style: BrandTypography.headlineLg.copyWith(
                              color: BrandColors.natureGreen,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your cozy digital sanctuary.',
                            style: BrandTypography.bodyMd.copyWith(
                              color: BrandColors.secondary.withValues(
                                alpha: 0.7,
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
        child: Container(color: Colors.transparent),
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
