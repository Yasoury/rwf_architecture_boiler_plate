import 'package:article/article.dart';
import 'package:article_list/article_list.dart';
import 'package:flutter/material.dart';
import 'package:news_repository/news_repository.dart';
import 'package:routemaster/routemaster.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required NewsRepository newsRepository,
}) {
  return {
    _PathConstants.homePath: (_) {
      return MaterialPage(
        child: ArticleListScreen(
          newsRepository: newsRepository,
          onArticleSelected: (articleTitle) {
            final navigation = routerDelegate.push<String?>(
              _PathConstants.articleDetailsPath(
                articleTitle: articleTitle,
              ),
            );
            return navigation.result;
          },
        ),
      );
    },
    _PathConstants.articleDetailsPath(): (info) {
      final articleTitle = info.pathParameters[_PathConstants.idPathParameter];

      return MaterialPage(
        name: 'article-details',
        child: ArticleScreen(
          newsRepository: newsRepository,
          articleTitle: Uri.decodeComponent(articleTitle ?? ''),
        ),
      );
    }
  };
}

class _PathConstants {
  const _PathConstants._();
  static String get homePath => '/';
  static String get idPathParameter => 'id';

  static String articleDetailsPath({
    String? articleTitle,
  }) =>
      '$homePath/article/${articleTitle != null ? Uri.encodeComponent(articleTitle) : ':$idPathParameter'}';
}
