import 'package:domain_models/domain_models.dart';
import 'package:news_api/news_api.dart';

extension ArticleListRMToDomain on List<ArticleRM> {
  List<Article> toDomainModel() {
    return map((article) => article.toDomainModel()).toList();
  }
}

extension ArticleRMToDomain on ArticleRM {
  Article toDomainModel() {
    return Article(
      source: source?.toDomainModel(),
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
    );
  }
}

extension SourceRMToDomain on SourceRM {
  Source toDomainModel() {
    return Source(
      id: id,
      name: name,
    );
  }
}

extension NewsListPageRMToDomain on NewsListPageRM {
  NewsListPage toDomainModel() {
    return NewsListPage(
      articles: articles?.toDomainModel() ?? [],
      isLastPage: (articles ?? []).isEmpty ? true : false,
    );
  }
}
