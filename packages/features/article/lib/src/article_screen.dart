import 'package:article/src/article_cubit.dart';
import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_repository/news_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:article/src/l10n/article_localizations.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({
    super.key,
    required this.newsRepository,
    required this.articleTitle,
  });

  final NewsRepository newsRepository;
  final String articleTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArticleCubit(
        newsRepository: newsRepository,
        articleTitle: articleTitle,
      ),
      child: const ArticleView(),
    );
  }
}

class ArticleView extends StatelessWidget {
  const ArticleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = ArticleLocalizations.of(context);

    return BlocBuilder<ArticleCubit, ArticleState>(
      builder: (context, state) {
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive breakpoints
              final isTablet = constraints.maxWidth >= 768;
              final isDesktop = constraints.maxWidth >= 1024;

              if (state is ArticleInProgress) {
                return const CenteredCircularProgressIndicator();
              } else if (state is ArticleFailure) {
                return _ArticleErrorView(
                  error: state.error ?? l10n.unknownErrorOccurred,
                  isTablet: isTablet,
                );
              } else if (state is ArticleLoaded) {
                return _ArticleContentView(
                  article: state.article,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}

class _ArticleErrorView extends StatelessWidget {
  const _ArticleErrorView({
    required this.error,
    required this.isTablet,
  });

  final String error;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final l10n = ArticleLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 80 : 64,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              l10n.articleNotFound,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: isTablet ? 24 : 20,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),
            ElevatedButton(
              onPressed: () {
                context.read<ArticleCubit>().retry();
              },
              child: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleContentView extends StatelessWidget {
  const _ArticleContentView({
    required this.article,
    required this.isTablet,
    required this.isDesktop,
  });

  final Article article;
  final bool isTablet;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final l10n = ArticleLocalizations.of(context);

    // Calculate responsive padding and constraints
    final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 16.0);
    final verticalPadding = isTablet ? 24.0 : 16.0;
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;

    return CustomScrollView(
      slivers: [
        // Responsive App Bar
        SliverAppBar(
          expandedHeight: _getAppBarHeight(context),
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeroImage(context),
            title: Text(
              article.title ?? l10n.article,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
            titlePadding: EdgeInsets.only(
              left: horizontalPadding,
              bottom: 16,
              right: horizontalPadding,
            ),
          ),
        ),

        // Article Content
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildArticleMetadata(context),
                    SizedBox(height: isTablet ? 24 : 16),
                    _buildArticleDescription(context),
                    SizedBox(height: isTablet ? 32 : 24),
                    _buildArticleContent(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getAppBarHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (isDesktop) return screenHeight * 0.4;
    if (isTablet) return screenHeight * 0.35;
    return screenHeight * 0.3;
  }

  Widget _buildHeroImage(BuildContext context) {
    if (article.urlToImage?.isNotEmpty == true) {
      return Image.network(
        article.urlToImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage(context);
        },
      );
    }
    return _buildPlaceholderImage(context);
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: isTablet ? 80 : 64,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildArticleMetadata(BuildContext context) {
    final l10n = ArticleLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.author?.isNotEmpty == true) ...[
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isTablet ? 20 : 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  l10n.byAuthor(article.author!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isTablet ? 16 : 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
        ],
        if (article.publishedAt?.isNotEmpty == true) ...[
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: isTablet ? 20 : 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                _formatDate(article.publishedAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isTablet ? 14 : 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildArticleDescription(BuildContext context) {
    if (article.description?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Text(
          article.description!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isTablet ? 18 : 16,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    final l10n = ArticleLocalizations.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Text(
              article.content ?? "",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isTablet ? 18 : 16,
                    height: 1.7,
                  ),
            ),
            Icon(
              Icons.info_outline,
              size: isTablet ? 48 : 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              l10n.fullArticleContentNotAvailable,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                  ),
              textAlign: TextAlign.center,
            ),
            if (article.url?.isNotEmpty == true) ...[
              SizedBox(height: isTablet ? 16 : 12),
              ElevatedButton.icon(
                onPressed: () => _launchURL(context, article.url!),
                icon: const Icon(Icons.open_in_new),
                label: Text(l10n.readFullArticle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final l10n = ArticleLocalizations.of(context);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, l10n.cannotOpenUrl);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, l10n.errorOpeningUrl);
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
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
