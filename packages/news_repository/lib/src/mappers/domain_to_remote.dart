import 'package:domain_models/domain_models.dart';
import 'package:news_api/news_api.dart';

extension ArticleListToRemote on List<Article> {
  List<ArticleRM> toRemoteModel() {
    return map((article) => article.toRemoteModel()).toList();
  }
}

extension ArticleToRemote on Article {
  ArticleRM toRemoteModel() {
    return ArticleRM(
      source: source?.toRemoteModel(),
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

extension SourceToRemote on Source {
  SourceRM toRemoteModel() {
    return SourceRM(
      id: id,
      name: name,
    );
  }
}

extension NewsListPageToRemote on NewsListPage {
  NewsListPageRM toRemoteModel() {
    return NewsListPageRM(
      status: 'ok', // Default status for outgoing requests
      totalResults: totalCount,
      articles: articles?.toRemoteModel(),
    );
  }
}
