import 'package:key_value_storage/key_value_storage.dart';

class NewsLocalStorage {
  NewsLocalStorage({
    required this.keyValueStorage,
  });

  final KeyValueStorage keyValueStorage;

  // Get all articles
  Future<List<ArticleCM>?> getArticles() async {
    return await keyValueStorage.articleCollection.where().findAll();
  }

  // Watch all articles stream
  Stream<List<ArticleCM>?> watchArticles() {
    return keyValueStorage.articleCollection
        .where()
        .watch(fireImmediately: true);
  }

  // Get article by ID
  Future<ArticleCM?> getArticleById(int id) async {
    return await keyValueStorage.articleCollection.get(id);
  }

  // Get article by title
  Future<ArticleCM?> getArticleByTitle(String title) async {
    return await keyValueStorage.articleCollection
        .filter()
        .titleEqualTo(title)
        .findFirst();
  }

  // Upsert single article
  Future<void> upsertArticle(ArticleCM articleCM) async {
    await keyValueStorage.writeIsarTxn(() async {
      await keyValueStorage.articleCollection.put(articleCM);
    });
  }

  // Upsert news list page (bulk insert/update)
  Future<void> upsertNewsListPage(List<ArticleCM> articles) async {
    await keyValueStorage.writeIsarTxn(() async {
      await keyValueStorage.articleCollection.putAll(articles);
    });
  }

  // Clear all cached news
  Future<void> clearAllCachedNews() async {
    await keyValueStorage.articleCollection.clear();
  }

  // Clear temporary cached news
  Future<void> clearTempCachedNews() async {
    await keyValueStorage.writeIsarTxn(() async {
      await keyValueStorage.articleCollection
          .filter()
          .isTempEqualTo(true)
          .deleteAll();
    });
  }

  // Get articles count
  Future<int> getArticlesCount() async {
    return await keyValueStorage.articleCollection.count();
  }

  // Check if article exists by title
  Future<bool> articleExistsByTitle(String title) async {
    final article = await getArticleByTitle(title);
    return article != null;
  }
}
