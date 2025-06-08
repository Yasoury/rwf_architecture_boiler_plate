import 'package:equatable/equatable.dart';

import 'article.dart';

class NewsListPage extends Equatable {
  final List<Article> articles;
  final bool isLastPage;

  NewsListPage({
    required this.articles,
    required this.isLastPage,
  });

  @override
  List<Object?> get props => [
        articles,
        isLastPage,
      ];
}
