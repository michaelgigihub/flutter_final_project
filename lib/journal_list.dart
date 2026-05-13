import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'brand_config.dart';
import 'widgets/app_bar.dart';
import 'widgets/journal_card.dart';
import 'widgets/stitched_container.dart';
import 'utils/formatter.dart';
import 'journal_entry.dart';
import 'auth page/login.dart';
import 'widgets/falling_leaves.dart';
import 'settings_page.dart';

class JournalListsPage extends StatefulWidget {
  const JournalListsPage({super.key});

  @override
  State<JournalListsPage> createState() => _JournalListsPageState();
}

class _JournalListsPageState extends State<JournalListsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _username = '';

  /// Debounce timer – cancelled & restarted on every keystroke.
  Timer? _debounce;

  /// Cached stream – created once so StreamBuilder never resubscribes
  /// on widget rebuilds (e.g. keyboard open/close).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _journalStream;

  @override
  void initState() {
    super.initState();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _journalStream = FirebaseFirestore.instance
        .collection('journal_entries')
        .where('user_id', isEqualTo: currentUserId)
        .snapshots();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _username = doc.data()?['username'] ?? '';
      });
    }
  }

  void _onSearchChanged() {
    // Cancel the previous timer if the user is still typing.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = _searchController.text.trim().toLowerCase();
      if (query != _searchQuery) {
        setState(() => _searchQuery = query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Returns true if the document matches the current [_searchQuery].
  bool _matchesQuery(Map<String, dynamic> data) {
    if (_searchQuery.isEmpty) return true;
    final title = (data['title'] ?? '').toString().toLowerCase();
    final content = (data['content'] ?? '').toString().toLowerCase();
    final mood = (data['mood'] ?? '').toString().toLowerCase();
    return title.contains(_searchQuery) ||
        content.contains(_searchQuery) ||
        mood.contains(_searchQuery);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BrandColors.neutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        title: Text(
          'Leaving so soon? 🐼',
          style: BrandTypography.headlineLg.copyWith(
            color: BrandColors.natureGreen,
            fontSize: 22,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: BrandTypography.bodyMd.copyWith(color: BrandColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Stay',
              style: BrandTypography.labelMd.copyWith(
                color: BrandColors.secondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.natureGreen,
              foregroundColor: BrandColors.neutral,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: BrandTypography.labelMd.copyWith(
                color: BrandColors.neutral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AnimatedImageButton(
                    imagePath: 'assets/images/logout_icon.png',
                    width: 40,
                    height: 40,
                    onTap: () => _showLogoutDialog(context),
                  ),
                  _AnimatedImageButton(
                    imagePath: 'assets/images/settings_icon.png',
                    width: 40,
                    height: 40,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 24, bottom: 8),
              height: 160,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: -10,
                    bottom: 0,
                    child: Image.asset(
                      _getPandaAsset(),
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 140,
                    top: 20,
                    right: 16,
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
                        child: Text.rich(
                          TextSpan(
                            children: _getSpeechBubbleText(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      StitchedContainer(
                        borderRadius: 16,
                        showShadow: false,
                        child: TextField(
                          controller: _searchController,
                          // onChanged fires ONLY when text changes — never on focus or
                          // cursor/selection events, preventing spurious list re-renders.
                          onChanged: (_) => _onSearchChanged(),
                          style: BrandTypography.bodyMd.copyWith(
                            color: BrandColors.secondary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search your soft thoughts...',
                            hintStyle: BrandTypography.bodyMd.copyWith(
                              color: BrandColors.secondary.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: BrandColors.natureGreen,
                            ),
                            // Clear button – only visible when there is text
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: BrandColors.natureGreen,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      // Explicitly trigger debounce since clear() does
                                      // not emit an onChanged event in all Flutter versions.
                                      _onSearchChanged();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      StreamBuilder<QuerySnapshot>(
                        stream: _journalStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: BrandColors.primary,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'Something went wrong 🐼\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: BrandTypography.bodyMd.copyWith(
                                    color: BrandColors.secondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'No journal entries yet.\nStart writing your story! ✨',
                                  textAlign: TextAlign.center,
                                  style: BrandTypography.bodyMd.copyWith(
                                    color: BrandColors.secondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final filteredDocs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return _matchesQuery(data);
                          }).toList();

                          if (filteredDocs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'No entries match "$_searchQuery" 🐼\nTry a different keyword.',
                                  textAlign: TextAlign.center,
                                  style: BrandTypography.bodyMd.copyWith(
                                    color: BrandColors.secondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: filteredDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              String formattedDate = 'Unknown';
                              if (data['date'] != null &&
                                  data['date'] is Timestamp) {
                                final dateTime = (data['date'] as Timestamp)
                                    .toDate();
                                formattedDate = DateFormatter.format(dateTime);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Slidable(
                                  key: ValueKey(doc.id),
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          FirebaseFirestore.instance
                                              .collection('journal_entries')
                                              .doc(doc.id)
                                              .delete();
                                        },
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ],
                                  ),
                                  child: JournalCard(
                                    imagePath: data['image_path'] ?? '',
                                    mood: data['mood'] ?? '',
                                    title: data['title'] ?? '',
                                    content: data['content'] ?? '',
                                    date: formattedDate,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              JournalEntryPage(
                                                mode: JournalEntryMode.edit,
                                                initialData: JournalEntryArgs(
                                                  id: doc.id,
                                                  title: data['title'] ?? '',
                                                  content:
                                                      data['content'] ?? '',
                                                  imagePath:
                                                      data['image_path'] ?? '',
                                                  mood: data['mood'] ?? '',
                                                  emotions:
                                                      (data['emotions']
                                                              as List<dynamic>?)
                                                          ?.map(
                                                            (e) => e.toString(),
                                                          )
                                                          .toList(),
                                                  dateLabel: formattedDate,
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const JournalEntryPage(mode: JournalEntryMode.create),
            ),
          );
        },
        child: Image.asset(
          'assets/images/panda_createnew.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
      extendBody: true,
    );
  }

  String _getPandaAsset() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'assets/images/panda_morning.gif';
    } else if (hour >= 12 && hour < 18) {
      return 'assets/images/panda_afternoon.gif';
    } else {
      return 'assets/images/panda_evening.gif';
    }
  }

  List<TextSpan> _getSpeechBubbleText() {
    final hour = DateTime.now().hour;
    final name = _username.isNotEmpty ? _username : 'friend';
    String greeting;
    String message;

    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning, $name! ';
      message = 'Start your day with a fresh thought. Here are your recent entries 🌿';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Good afternoon, $name! ';
      message = 'How\'s your day going? Take a peek at your soft reflections 🌸';
    } else {
      greeting = 'Good evening, $name! ';
      message = 'Time to wind down. Revisit your recent entries and reflect 🌙';
    }

    return [
      TextSpan(
        text: greeting,
        style: BrandTypography.bodyMd.copyWith(
          color: BrandColors.natureGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      TextSpan(
        text: message,
        style: BrandTypography.bodyMd.copyWith(
          color: BrandColors.secondary.withValues(alpha: 0.8),
        ),
      ),
    ];
  }
}

class _AnimatedImageButton extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _AnimatedImageButton({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  State<_AnimatedImageButton> createState() => _AnimatedImageButtonState();
}

class _AnimatedImageButtonState extends State<_AnimatedImageButton>
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.contain,
          ),
        ),
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

