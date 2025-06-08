import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    required this.title,
    required this.content,
    this.author,
    this.publishedAt,
    this.imageUrl,
    this.onTap,
    super.key,
  });

  final String title;
  final String content;
  final String? author;
  final String? publishedAt;
  final String? imageUrl;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final author = this.author;
    final imageUrl = this.imageUrl;

    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: theme.surfaceColor,
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(Spacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.headlineTextStyle.copyWith(
                      fontSize: FontSize.large,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.small),
                  Text(
                    content,
                    style: theme.bodyTextStyle.copyWith(
                      fontSize: FontSize.medium,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (author != null || publishedAt != null) ...[
                    const SizedBox(height: Spacing.medium),
                    Row(
                      children: [
                        if (author != null)
                          Expanded(
                            child: Text(
                              author,
                              style: theme.captionTextStyle.copyWith(
                                fontSize: FontSize.small,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (publishedAt != null)
                          Text(
                            _formatDate(publishedAt!),
                            style: theme.captionTextStyle.copyWith(
                              fontSize: FontSize.small,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
