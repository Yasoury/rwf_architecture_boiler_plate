import 'article.dart';

class NewsListPageRM {
  String? status;
  int? totalResults;
  List<ArticleRM>? articles;

  NewsListPageRM({this.status, this.totalResults, this.articles});

  factory NewsListPageRM.fromJson(Map<String, dynamic> json) {
    return NewsListPageRM(
      status: json['status'] as String?,
      totalResults: json['totalResults'] as int?,
      articles: (json['articles'] as List<dynamic>?)
          ?.map((e) => ArticleRM.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'totalResults': totalResults,
        'articles': articles?.map((e) => e.toJson()).toList(),
      };
}
