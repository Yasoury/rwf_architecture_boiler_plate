import 'package:key_value_storage/key_value_storage.dart';

class NewsLocalStorage {
  NewsLocalStorage({
    required this.keyValueStorage,
  });

  final KeyValueStorage keyValueStorage;

  // Get all articles
  Future<List<ArticleCM>> getArticles() async {
    final box = await keyValueStorage.articlesBox;
    return box.values.toList();
  }

  // Watch all articles stream
  Stream<List<ArticleCM>> watchArticles() async* {
    final box = await keyValueStorage.articlesBox;

    // Initial emission
    yield box.values.toList();

    // Listen to box changes
    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  }

  // Get article by title
  Future<ArticleCM?> getArticleByTitle(String title) async {
    final box = await keyValueStorage.articlesBox;
    try {
      return box.values.firstWhere(
        (article) => article.title == title,
      );
    } catch (e) {
      return null; // Return null if not found
    }
  }

  // Upsert single article
  Future<void> upsertArticle(ArticleCM articleCM) async {
    final box = await keyValueStorage.articlesBox;

    // Check if article already exists by title
    final existingKey = await _findArticleKeyByTitle(articleCM.title);

    if (existingKey != null) {
      // Update existing article
      await box.put(existingKey, articleCM);
    } else {
      // Add new article
      await box.add(articleCM);
    }
  }

  // Upsert news list page (bulk insert/update)
  Future<void> upsertNewsListPage(List<ArticleCM> articles) async {
    final box = await keyValueStorage.articlesBox;

    for (final article in articles) {
      final existingKey = await _findArticleKeyByTitle(article.title);

      if (existingKey != null) {
        // Update existing article
        await box.put(existingKey, article);
      } else {
        // Add new article
        await box.add(article);
      }
    }
  }

  // Clear all cached news
  Future<void> clearAllCachedNews() async {
    final box = await keyValueStorage.articlesBox;
    await box.clear();
  }

  // Clear temporary cached news
  Future<void> clearTempCachedNews() async {
    final box = await keyValueStorage.articlesBox;

    // Get all keys of temporary articles
    final keysToDelete = <dynamic>[];
    for (final key in box.keys) {
      final article = box.get(key);
      if (article?.isTemp == true) {
        keysToDelete.add(key);
      }
    }

    // Delete temporary articles
    await box.deleteAll(keysToDelete);
  }

  // Get articles count
  Future<int> getArticlesCount() async {
    final box = await keyValueStorage.articlesBox;
    return box.length;
  }

  // Helper method to find article key by title
  Future<dynamic> _findArticleKeyByTitle(String? title) async {
    if (title == null) return null;

    final box = await keyValueStorage.articlesBox;
    for (final key in box.keys) {
      final article = box.get(key);
      if (article?.title == title) {
        return key;
      }
    }
    return null;
  }
}
