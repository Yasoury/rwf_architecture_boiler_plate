import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';

extension ArticleListCMToDomain on List<ArticleCM> {
  List<Article> toDomainModel() {
    return map((article) => article.toDomainModel()).toList();
  }
}

extension ArticleToDomain on ArticleCM {
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
      isTemp: isTemp,
    );
  }
}

extension SourceToDomain on SourceCM {
  Source toDomainModel() {
    return Source(
      id: id,
      name: name,
    );
  }
}
