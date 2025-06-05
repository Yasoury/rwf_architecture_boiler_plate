import 'package:key_value_storage/key_value_storage.dart';

part 'article.g.dart';

@collection
class ArticleCM {
  String? title;
  Id? get id => fastHash(title!);
  SourceCM? source;
  String? author;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;
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

int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
