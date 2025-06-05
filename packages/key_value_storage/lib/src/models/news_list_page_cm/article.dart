import 'package:key_value_storage/key_value_storage.dart';

part 'article.g.dart';

@collection
class ArticleCM {
  Id? id = Isar.autoIncrement;
  SourceCM? source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;

  ArticleCM({
    this.id,
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });
}
