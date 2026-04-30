import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_config.dart';
import 'widgets/journal_card.dart';
import 'widgets/stitched_container.dart';
import 'utils/formatter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.tertiary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: BrandColors.neutral,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            border: const Border(
              bottom: BorderSide(color: BrandColors.primary, width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: BrandColors.primary.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: const EdgeInsets.all(16),
                icon: const Icon(Icons.face, color: BrandColors.primary),
                onPressed: () {},
              ),
              Text(
                'PanDiary',
                style: BrandTypography.headlineLg.copyWith(
                  color: BrandColors.primary,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                padding: const EdgeInsets.all(16),
                icon: const Icon(Icons.settings, color: BrandColors.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                  color: BrandColors.secondary.withOpacity(0.6),
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
                      color: BrandColors.secondary.withOpacity(0.4),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: BrandColors.primary,
                    ),
                    // Clear button – only visible when there is text
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: BrandColors.primary,
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                            color: BrandColors.secondary.withOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  }

                  // Empty collection state
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No journal entries yet.\nStart writing your story! ✨',
                          textAlign: TextAlign.center,
                          style: BrandTypography.bodyMd.copyWith(
                            color: BrandColors.secondary.withOpacity(0.6),
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
                            color: BrandColors.secondary.withOpacity(0.6),
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
                      if (data['date'] != null && data['date'] is Timestamp) {
                        final dateTime =
                            (data['date'] as Timestamp).toDate();
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

              const SizedBox(height: 100), // Bottom padding for nav bar space
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}
