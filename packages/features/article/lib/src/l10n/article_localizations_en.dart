// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'article_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ArticleLocalizationsEn extends ArticleLocalizations {
  ArticleLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get unknownErrorOccurred => 'Unknown error occurred';

  @override
  String get articleNotFound => 'Article Not Found';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get article => 'Article';

  @override
  String byAuthor(String author) {
    return 'By $author';
  }

  @override
  String get fullArticleContentNotAvailable => 'Full article content is not available.';

  @override
  String get readFullArticle => 'Read Full Article';

  @override
  String get cannotOpenUrl => 'Cannot open URL';

  @override
  String get errorOpeningUrl => 'Error opening URL';
}
