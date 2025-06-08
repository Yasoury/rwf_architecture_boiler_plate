import 'package:article_list/article_list.dart';

import 'package:flutter/material.dart';

import 'package:news_repository/news_repository.dart';

import 'package:routemaster/routemaster.dart';

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required NewsRepository newsRepository,
  //TODOTip add the neassery Repository
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
      return MaterialPage(
          child:
              Container() /* ArticleScreen(
          newsRepository: newsRepository,
          
        ), */
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
      '$homePath/article/${articleTitle ?? ':$idPathParameter'}';
}
