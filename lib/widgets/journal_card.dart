import 'package:flutter/material.dart';
import '../brand_config.dart';
import 'stitched_container.dart';

class JournalCard extends StatelessWidget {
  final String imagePath;
  final String mood;
  final String date;
  final String title;
  final String content;
  final VoidCallback? onTap;

  const JournalCard({
    super.key,
    required this.imagePath,
    required this.mood,
    required this.date,
    required this.title,
    required this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StitchedContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Row(
            children: [
              // Image container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: BrandColors.tertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imagePath.isNotEmpty
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: BrandColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BrandColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: BrandColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            mood,
                            style: BrandTypography.labelMd.copyWith(
                              color: BrandColors.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: BrandTypography.labelMd.copyWith(
                            color: BrandColors.secondary.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.headlineMd.copyWith(
                        color: BrandColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BrandTypography.bodyMd.copyWith(
                        color: BrandColors.secondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
