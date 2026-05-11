import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/stitched_container.dart';
import 'widgets/journal_badge.dart';
import 'brand_config.dart';
import 'widgets/app_bar.dart';

enum JournalEntryMode { create, edit }

class JournalEntryArgs {
  final String? id;
  final String? title;
  final String? content;
  final String? imagePath;
  final String? mood;
  final String? dateLabel;
  final String? weatherLabel;

  const JournalEntryArgs({
    this.id,
    this.title,
    this.content,
    this.imagePath,
    this.mood,
    this.dateLabel,
    this.weatherLabel,
  });
}

class JournalEntryPage extends StatefulWidget {
  final JournalEntryMode mode;
  final JournalEntryArgs? initialData;

  const JournalEntryPage({
    super.key,
    this.mode = JournalEntryMode.create,
    this.initialData,
  });

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isEditing;
  bool _isSaving = false;
  String? _entryId;
  String _imagePath = '';
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _pickedImageBytes;
  bool _isInitialImageRemoved = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _titleController = TextEditingController(text: data?.title ?? '');
    _contentController = TextEditingController(text: data?.content ?? '');
    _entryId = data?.id;
    _imagePath = data?.imagePath ?? '';
    _isEditing = widget.mode == JournalEntryMode.create;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _toggleEdit() async {
    if (_isSaving) return;
    if (_isEditing) {
      FocusScope.of(context).unfocus();
      final saved = await _saveEntry();
      if (!saved) return;
    }
    if (!mounted) return;
    setState(() => _isEditing = !_isEditing);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _saveEntry() async {
    if (_isSaving) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in to save.');
      return false;
    }

    setState(() => _isSaving = true);

    try {
      final entries = FirebaseFirestore.instance.collection('journal_entries');
      final docRef = _entryId == null ? entries.doc() : entries.doc(_entryId);
      _entryId ??= docRef.id;

      var imageUrl = _imagePath;
      if (_isInitialImageRemoved && _pickedImageBytes == null) {
        imageUrl = '';
      }

      if (_pickedImageBytes != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('journal_images')
            .child(user.uid)
            .child('${_entryId!}.jpg');

        await storageRef.putData(
          _pickedImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await storageRef.getDownloadURL();
      }

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'image_path': imageUrl,
        'user_id': user.uid,
      };

      if (widget.mode == JournalEntryMode.create) {
        data['date'] = FieldValue.serverTimestamp();
        await docRef.set(data);
      } else {
        await docRef.update(data);
      }

      setState(() {
        _imagePath = imageUrl;
        _pickedImageBytes = null;
        _isInitialImageRemoved = false;
      });

      return true;
    } catch (e) {
      _showSnackBar('Failed to save entry.');
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedImageBytes = bytes;
        _isInitialImageRemoved = false;
      });
    }
  }

  void _clearImage() {
    if (!_isEditing) return;
    setState(() {
      if (_pickedImageBytes != null) {
        _pickedImageBytes = null;
      } else {
        _isInitialImageRemoved = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.tertiary,
      body: SafeArea(
        child: CustomPaint(
          painter: PaperGridPainter(),
          child: Stack(
            children: [
              Positioned(
                top: 48,
                left: 8,
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
                bottom: 96,
                right: 16,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Icon(
                    Icons.spa,
                    size: 64,
                    color: BrandColors.primary.withValues(alpha: 0.4),
                  ),
                ),
              ),
              Column(
                children: [
                  ReusableAppBar(
                    leftWidget: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: BrandColors.natureGreen,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        hoverColor: BrandColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    middleWidget: Text(
                      'Entry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: BrandColors.natureGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                    rightWidget: CustomPaint(
                      foregroundPainter: DashedBorderPainter(
                        color: BrandColors.primary,
                        strokeWidth: 2,
                        gap: 4,
                        dashWidth: 6,
                        borderRadius: 9999,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _toggleEdit,
                        icon: Icon(
                          _isEditing ? Icons.check : Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : (_isEditing ? 'Done' : 'Edit'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.natureGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ).copyWith(
                              shadowColor: WidgetStateProperty.all(
                                BrandColors.primary.withValues(alpha: 0.4),
                              ),
                              elevation: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.hovered))
                                  return 6;
                                return 4;
                              }),
                            ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetadata(),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _titleController,
                            readOnly: !_isEditing,
                            showCursor: _isEditing,
                            enableInteractiveSelection: _isEditing,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              hintText: 'Add a title',
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.28,
                              letterSpacing: -0.56,
                              color: const Color(0xFF292524),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPolaroid(),
                          const SizedBox(height: 16),
                          _buildJournalText(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    final data = widget.initialData;
    final dateLabel = data?.dateLabel ?? 'October 24, 2023';
    final moodLabel = data?.mood ?? 'Cozy';
    final weatherLabel = data?.weatherLabel ?? 'Sunny';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        JournalBadge(
          icon: Icons.calendar_today,
          label: dateLabel,
          backgroundColor: const Color(0xFFFFEDD5),
          textColor: const Color(0xFF9A3412),
          borderColor: const Color(0xFFFDBA74),
        ),
        JournalBadge(
          icon: Icons.sentiment_very_satisfied,
          label: moodLabel,
          backgroundColor: const Color(0xFFFFE4E6),
          textColor: const Color(0xFF9F1239),
          borderColor: const Color(0xFFFDA4AF),
        ),
        JournalBadge(
          icon: Icons.wb_sunny,
          label: weatherLabel,
          backgroundColor: const Color(0xFFE0F2FE),
          textColor: const Color(0xFF075985),
          borderColor: const Color(0xFF7DD3FC),
        ),
      ],
    );
  }

  Widget _buildPolaroid() {
    final hasPickedImage = _pickedImageBytes != null;
    final hasNetworkImage = _imagePath.isNotEmpty && !_isInitialImageRemoved;
    final hasImage = hasPickedImage || hasNetworkImage;
    return Center(
      child: Transform.rotate(
        angle: -0.05,
        child: Container(
          width: 320,
          margin: const EdgeInsets.only(top: 8, bottom: 16),
          child: CustomPaint(
            foregroundPainter: DashedBorderPainter(
              color: BrandColors.primary,
              strokeWidth: 4,
              gap: 8,
              dashWidth: 12,
              borderRadius: 16,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: BrandColors.primary.withValues(alpha: 0.4),
                    offset: const Offset(0, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: BrandColors.tertiary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BrandColors.primary,
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: hasImage ? null : _pickImage,
                              child: _buildImageContent(
                                hasPickedImage: hasPickedImage,
                                hasNetworkImage: hasNetworkImage,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'So peaceful...',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontSize: 18,
                          color: Color(0xFF78716C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  if (hasImage)
                    Positioned(
                      top: -24,
                      right: -24,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: CustomPaint(
                          foregroundPainter: DashedBorderPainter(
                            color: const Color(0xFFFDA4AF),
                            strokeWidth: 2,
                            gap: 4,
                            dashWidth: 6,
                            borderRadius: 24,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _isEditing ? _clearImage : null,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE4E6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(254, 205, 211, 1),
                                      offset: Offset(0, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isEditing
                                      ? Icons.delete_outline
                                      : Icons.favorite,
                                  color: _isEditing
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFF43F5E),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalText() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: BrandColors.primary,
          strokeWidth: 2,
          gap: 6,
          dashWidth: 8,
          borderRadius: 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: BrandColors.primary.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextField(
                  controller: _contentController,
                  readOnly: !_isEditing,
                  showCursor: _isEditing,
                  enableInteractiveSelection: _isEditing,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    filled: false,
                    hintText: 'Write your journal entry here...',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF44403C),
                    height: 1.77,
                  ),
                ),
              ),
              const Positioned(
                bottom: 16,
                right: 16,
                child: Opacity(
                  opacity: 0.3,
                  child: Icon(
                    Icons.cruelty_free,
                    size: 36,
                    color: BrandColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent({
    required bool hasPickedImage,
    required bool hasNetworkImage,
  }) {
    if (hasPickedImage) {
      return Image.memory(_pickedImageBytes!, fit: BoxFit.cover);
    }

    if (hasNetworkImage) {
      return Image.network(
        _imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFE7E5E4),
      child: Center(
        child: Icon(
          Icons.add,
          size: 36,
          color: BrandColors.secondary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class PaperGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BrandColors.primary
      ..strokeWidth = 2;

    for (double y = 0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
