import 'package:hive/hive.dart';
import 'source.dart';

part 'article.g.dart';

@HiveType(typeId: 3)
class ArticleCM extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  SourceCM? source;

  @HiveField(2)
  String? author;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? url;

  @HiveField(5)
  String? urlToImage;

  @HiveField(6)
  String? publishedAt;

  @HiveField(7)
  String? content;

  @HiveField(8)
  bool? isTemp;

  ArticleCM({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.isTemp,
  });
}
