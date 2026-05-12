import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../brand_config.dart';
import '../journal_list.dart';
import '../widgets/falling_leaves.dart';

class PinInputPage extends StatefulWidget {
  final String email;
  final String? username;
  final bool isCreateMode;

  const PinInputPage({
    super.key,
    required this.email,
    this.username,
    required this.isCreateMode,
  });

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  String _pin = '';
  final int _pinLength = 6;
  bool _isLoading = false;

  /// For create-mode PIN confirmation flow.
  String? _firstPin;
  bool _isConfirming = false;

  void _onNumberTap(String number) {
    if (_isLoading) return;
    if (_pin.length < _pinLength) {
      setState(() => _pin += number);
      if (_pin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _onBackspaceTap() {
    if (_isLoading) return;
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _handlePinComplete() async {
    if (widget.isCreateMode) {
      await _handleCreateFlow();
    } else {
      await _handleLoginFlow();
    }
  }

  Future<void> _handleCreateFlow() async {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
      return;
    }

    if (_pin != _firstPin) {
      _showError("PINs don't match! Let's try again 🐼");
      setState(() {
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
      return;
    }

    // PINs match — create the user via Firebase Auth
    setState(() => _isLoading = true);
    try {
      var userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: _pin,
      );

      await userCredential.user!.updateDisplayName(widget.username ?? '');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'username': widget.username ?? '',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const JournalListsPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message ?? 'Registration failed 🐼');
      setState(() {
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      setState(() {
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLoginFlow() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.email,
        password: _pin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const JournalListsPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(e.message ?? 'Wrong PIN! Try again 🐼');
      setState(() => _pin = '');
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      setState(() => _pin = '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style:
                BrandTypography.bodyMd.copyWith(color: BrandColors.neutral)),
        backgroundColor: BrandColors.natureGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _headerTitle {
    if (widget.isCreateMode) {
      return _isConfirming ? 'Confirm Your PIN' : 'Set Your Secret PIN';
    }
    return 'Welcome Back';
  }

  String get _headerSubtitle {
    if (widget.isCreateMode) {
      return _isConfirming
          ? 'Enter the same PIN again'
          : 'Choose a 6-digit PIN';
    }
    return 'Enter your secret PIN';
  }

  @override
  Widget build(BuildContext context) {
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
          // Back button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                padding: const EdgeInsets.all(16),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: BrandColors.natureGreen, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/panda_lock.gif',
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(_headerSubtitle,
                            style: BrandTypography.headlineMd.copyWith(
                                color: BrandColors.secondary
                                    .withValues(alpha: 0.8))),
                        const SizedBox(height: 48),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: BrandColors.natureGreen)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:
                                    List.generate(_pinLength, (index) {
                                  bool isFilled = index < _pin.length;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isFilled
                                          ? BrandColors.natureGreen
                                          : BrandColors.neutral,
                                      border: isFilled
                                          ? null
                                          : Border.all(
                                              color:
                                                  BrandColors.natureGreen,
                                              width: 2),
                                      boxShadow: isFilled
                                          ? [
                                              BoxShadow(
                                                color: BrandColors
                                                    .natureGreen
                                                    .withValues(
                                                        alpha: 0.3),
                                                blurRadius: 0,
                                                offset:
                                                    const Offset(0, 2),
                                              ),
                                            ]
                                          : const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                                blurStyle:
                                                    BlurStyle.inner,
                                              ),
                                            ],
                                    ),
                                  );
                                }),
                              ),
                      ],
                    ),
                    Container(
                      width: 280,
                      margin: const EdgeInsets.only(bottom: 48),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _buildNumberButton('1'),
                          _buildNumberButton('2'),
                          _buildNumberButton('3'),
                          _buildNumberButton('4'),
                          _buildNumberButton('5'),
                          _buildNumberButton('6'),
                          _buildNumberButton('7'),
                          _buildNumberButton('8'),
                          _buildNumberButton('9'),
                          const SizedBox(),
                          _buildNumberButton('0'),
                          GestureDetector(
                            onTap: _onBackspaceTap,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent),
                              child: Icon(Icons.backspace_outlined,
                                  color: BrandColors.secondary
                                      .withValues(alpha: 0.6),
                                  size: 32),
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
    );
  }

  Widget _buildNumberButton(String number) {
    return _AnimatedNumberButton(
      number: number,
      onTap: () => _onNumberTap(number),
    );
  }
}

class _AnimatedNumberButton extends StatefulWidget {
  final String number;
  final VoidCallback onTap;

  const _AnimatedNumberButton({
    required this.number,
    required this.onTap,
  });

  @override
  State<_AnimatedNumberButton> createState() => _AnimatedNumberButtonState();
}

class _AnimatedNumberButtonState extends State<_AnimatedNumberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    widget.onTap();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BrandColors.neutral,
            shape: BoxShape.circle,
            border: Border.all(color: BrandColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: BrandColors.primary.withValues(alpha: 0.5),
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(widget.number,
              style: BrandTypography.headlineLg
                  .copyWith(color: BrandColors.secondary)),
        ),
      ),
    );
  }
}
