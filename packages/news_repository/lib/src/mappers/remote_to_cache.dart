import 'package:key_value_storage/key_value_storage.dart';
import 'package:news_api/news_api.dart';

extension ArticleListToCache on List<ArticleRM> {
  List<ArticleCM> toCacheModel() {
    return map((article) => article.toCacheModel()).toList();
  }
}

extension ArticleToCache on ArticleRM {
  ArticleCM toCacheModel() {
    return ArticleCM(
      source: source?.toCacheModel(),
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

extension SourceToCache on SourceRM {
  SourceCM toCacheModel() {
    return SourceCM(
      id: id?.toString(), // Convert dynamic to String for cache
      name: name,
    );
  }
}

extension NewsListPageToCache on NewsListPageRM {
  List<ArticleCM> toCacheModel() {
    return articles?.toCacheModel() ?? [];
  }
}
