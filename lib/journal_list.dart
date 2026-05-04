import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'brand_config.dart';
import 'widgets/app_bar.dart';
import 'widgets/journal_card.dart';
import 'widgets/stitched_container.dart';
import 'utils/formatter.dart';
import 'journal_entry.dart';
import 'auth page/login.dart';

class JournalListsPage extends StatefulWidget {
  const JournalListsPage({super.key});

  @override
  State<JournalListsPage> createState() => _JournalListsPageState();
}

class _JournalListsPageState extends State<JournalListsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Debounce timer – cancelled & restarted on every keystroke.
  Timer? _debounce;

  /// Cached stream – created once so StreamBuilder never resubscribes
  /// on widget rebuilds (e.g. keyboard open/close).
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _journalStream;

  @override
  void initState() {
    super.initState();
    _journalStream = FirebaseFirestore.instance
        .collection('journal_entries')
        .snapshots();
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
          style: BrandTypography.bodyMd.copyWith(
            color: BrandColors.secondary,
          ),
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
      backgroundColor: BrandColors.tertiary,
      body: SafeArea(
        child: Column(
          children: [
            ReusableAppBar(
              leftWidget: IconButton(
                padding: const EdgeInsets.all(8),
                icon: const Icon(Icons.face, color: BrandColors.natureGreen),
                onPressed: () => _showLogoutDialog(context),
              ),
              middleWidget: Text(
                'PanDiary',
                style: BrandTypography.headlineLg.copyWith(
                  color: BrandColors.natureGreen,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
              rightWidget: IconButton(
                padding: const EdgeInsets.all(8),
                icon: const Icon(
                  Icons.settings,
                  color: BrandColors.natureGreen,
                ),
                onPressed: () {},
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
                      const SizedBox(height: 8),
                      Text(
                        'Recent Entries',
                        style: BrandTypography.headlineLg.copyWith(
                          color: BrandColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your soft reflections',
                        style: BrandTypography.bodyMd.copyWith(
                          color: BrandColors.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
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
                              color: BrandColors.secondary.withValues(alpha: 0.4),
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

                      // Firestore StreamBuilder – reads journal entries in real time
                      StreamBuilder<QuerySnapshot>(
                        stream: _journalStream,
                        builder: (context, snapshot) {
                          // Loading state
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

                          // Error state
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

                          // Empty collection state
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

                          // Filter documents by the current search query
                          final filteredDocs = snapshot.data!.docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return _matchesQuery(data);
                          }).toList();

                          // No results after filtering
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

                          // Build journal cards from filtered results
                          return Column(
                            children: filteredDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              // Formatting date
                              String formattedDate = 'Unknown';
                              if (data['date'] != null &&
                                  data['date'] is Timestamp) {
                                final dateTime = (data['date'] as Timestamp)
                                    .toDate();
                                formattedDate = DateFormatter.format(dateTime);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: JournalCard(
                                  imagePath: data['image_path'] ?? '',
                                  mood: data['mood'] ?? '',
                                  title: data['title'] ?? '',
                                  content: data['content'] ?? '',
                                  date: formattedDate,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalEntryPage()),
          );
        },
        backgroundColor: BrandColors.natureGreen,
        foregroundColor: BrandColors.tertiary,
        elevation: 4,
        shape: CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      extendBody: true,
    );
  }
}
