import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../brand_config.dart';
import '../services/auth_service.dart';
import '../journal_list.dart';
import 'auth_mode.dart';

class PinInputPage extends StatefulWidget {
  final String username;
  final AuthMode mode;

  const PinInputPage({
    super.key,
    required this.username,
    required this.mode,
  });

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  String _pin = '';
  final int _pinLength = 4;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  /// For create-mode PIN confirmation flow.
  /// `null` means we're still on the first entry.
  String? _firstPin;
  bool _isConfirming = false;

  void _onNumberTap(String number) {
    if (_isLoading) return;
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });
      if (_pin.length == _pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _onBackspaceTap() {
    if (_isLoading) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handlePinComplete() async {
    if (widget.mode == AuthMode.create) {
      await _handleCreateFlow();
    } else {
      await _handleLoginFlow();
    }
  }

  Future<void> _handleCreateFlow() async {
    if (!_isConfirming) {
      // First PIN entry — save it and ask for confirmation
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _isConfirming = true;
      });
      return;
    }

    // Second entry — compare with first
    if (_pin != _firstPin) {
      _showError("PINs don't match! Let's try again 🐼");
      setState(() {
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
      return;
    }

    // PINs match — create the user
    setState(() => _isLoading = true);
    try {
      await _authService.createUser(widget.username, _pin);
      await _authService.saveSession(widget.username);
      if (!mounted) return;
      _navigateToJournal();
    } on StateError catch (e) {
      if (!mounted) return;
      _showError(e.message);
      setState(() {
        _pin = '';
        _firstPin = null;
        _isConfirming = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again 🐼');
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
      final docId = await _authService.login(widget.username, _pin);
      if (!mounted) return;

      if (docId == null) {
        _showError('Wrong PIN! Try again 🐼');
        setState(() => _pin = '');
        return;
      }

      await _authService.saveSession(widget.username);
      if (!mounted) return;
      _navigateToJournal();
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again 🐼');
      setState(() => _pin = '');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToJournal() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const JournalListsPage()),
      (route) => false,
    );
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

  /// Dynamic header text based on mode and confirm state.
  String get _headerTitle {
    if (widget.mode == AuthMode.create) {
      return _isConfirming ? 'Confirm Your PIN' : 'Set Your Secret PIN';
    }
    return 'Welcome Back';
  }

  String get _headerSubtitle {
    if (widget.mode == AuthMode.create) {
      return _isConfirming ? 'Enter the same PIN again' : 'Choose a 4-digit PIN';
    }
    return 'Enter your secret PIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.tertiary,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/pin_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(
                color: BrandColors.tertiary.withValues(alpha: 0.8),
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                padding: const EdgeInsets.all(16),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: BrandColors.natureGreen,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 32),
                    // Header Section
                    Column(
                      children: [
                        // Lock Icon Container
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: BrandColors.neutral,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BrandColors.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BrandColors.primary.withValues(alpha: 0.2),
                                blurRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            widget.mode == AuthMode.create
                                ? (_isConfirming ? Icons.verified : Icons.lock_open)
                                : Icons.lock,
                            color: BrandColors.natureGreen,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _headerTitle,
                          style: BrandTypography.headlineLg.copyWith(
                            color: BrandColors.natureGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _headerSubtitle,
                          style: BrandTypography.bodyMd.copyWith(
                            color: BrandColors.secondary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // PIN Placeholders
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: BrandColors.natureGreen,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_pinLength, (index) {
                                  bool isFilled = index < _pin.length;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
                                              color: BrandColors.natureGreen,
                                              width: 2,
                                            ),
                                      boxShadow: isFilled
                                          ? [
                                              BoxShadow(
                                                color: BrandColors.natureGreen.withValues(alpha: 0.3),
                                                blurRadius: 0,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : const [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 2,
                                                offset: Offset(0, 1),
                                                blurStyle: BlurStyle.inner,
                                              ),
                                            ],
                                    ),
                                  );
                                }),
                              ),
                      ],
                    ),
                    
                    // Number Pad Section
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
                          const SizedBox(), // Empty
                          _buildNumberButton('0'),
                          // Backspace Button
                          GestureDetector(
                            onTap: _onBackspaceTap,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: Icon(
                                Icons.backspace_outlined,
                                color: BrandColors.secondary.withValues(alpha: 0.6),
                                size: 32,
                              ),
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
    return GestureDetector(
      onTap: () => _onNumberTap(number),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BrandColors.neutral,
          shape: BoxShape.circle,
          border: Border.all(
            color: BrandColors.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: BrandColors.primary.withValues(alpha: 0.5),
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          number,
          style: BrandTypography.headlineLg.copyWith(
            color: BrandColors.secondary,
          ),
        ),
      ),
    );
  }
}
