import 'package:domain_models/domain_models.dart';

import 'package:key_value_storage/key_value_storage.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:news_api/news_api.dart';
import 'package:news_repository/src/mappers/mappers.dart';
import 'package:news_repository/src/news_local_storage.dart';

class NewsRepository {
  NewsRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting NewsLocalStorage? localStorage,
  }) : _localStorage = localStorage ??
            NewsLocalStorage(
              keyValueStorage: keyValueStorage,
            );

  final NewsApi remoteApi;
  final NewsLocalStorage _localStorage;

  Stream<NewsListPage> getNewsListPage(
    int pageNumber,
    String searchTerm, {
    required NewsListPageFetchPolicy fetchPolicy,
  }) async* {
    final isSearching = searchTerm.isNotEmpty;
    final isFetchPolicyNetworkOnly =
        fetchPolicy == NewsListPageFetchPolicy.networkOnly;

    // Modified: Only skip cache for networkOnly policy
    // Still cache search results for better user experience
    final shouldSkipCacheLookup = isFetchPolicyNetworkOnly;

    if (shouldSkipCacheLookup) {
      final freshPage = await _getNewsListPageFromNetwork(
        pageNumber,
        searchTerm,
      );
      yield freshPage;
    } else {
      // Enhanced: Get cached articles with search consideration
      final cachedArticles = isSearching
          ? await _localStorage.searchCachedArticles(searchTerm)
          : await _localStorage.getArticles();

      final isFetchPolicyCacheAndNetwork =
          fetchPolicy == NewsListPageFetchPolicy.cacheAndNetwork;
      final isFetchPolicyCachePreferably =
          fetchPolicy == NewsListPageFetchPolicy.cachePreferably;

      final shouldEmitCachedPageInAdvance =
          isFetchPolicyCachePreferably || isFetchPolicyCacheAndNetwork;

      if (shouldEmitCachedPageInAdvance && cachedArticles.isNotEmpty) {
        // Enhanced: Better pagination handling for cache
        final startIndex = (pageNumber - 1) * 20; // Assuming 20 items per page
        final endIndex = startIndex + 20;
        final pageArticles = cachedArticles.length > startIndex
            ? cachedArticles.sublist(
                startIndex,
                endIndex > cachedArticles.length
                    ? cachedArticles.length
                    : endIndex)
            : <ArticleCM>[];

        if (pageArticles.isNotEmpty) {
          yield NewsListPage(
            isLastPage: endIndex >= cachedArticles.length,
            articles: pageArticles.toDomainModel(),
          );

          if (isFetchPolicyCachePreferably) {
            return;
          }
        }
      }

      try {
        final freshPage = await _getNewsListPageFromNetwork(
          pageNumber,
          searchTerm,
        );
        yield freshPage;
      } catch (error) {
        final isFetchPolicyNetworkPreferably =
            fetchPolicy == NewsListPageFetchPolicy.networkPreferably;

        if (cachedArticles.isNotEmpty && isFetchPolicyNetworkPreferably) {
          // Enhanced: Better error recovery with pagination
          final startIndex = (pageNumber - 1) * 20;
          final endIndex = startIndex + 20;
          final pageArticles = cachedArticles.length > startIndex
              ? cachedArticles.sublist(
                  startIndex,
                  endIndex > cachedArticles.length
                      ? cachedArticles.length
                      : endIndex)
              : <ArticleCM>[];

          if (pageArticles.isNotEmpty) {
            yield NewsListPage(
              isLastPage: endIndex >= cachedArticles.length,
              articles: pageArticles.toDomainModel(),
            );
            return;
          }
        }
        rethrow;
      }
    }
  }

  Future<NewsListPage> _getNewsListPageFromNetwork(
    int pageNumber,
    String searchTerm,
  ) async {
    try {
      final apiPage = await remoteApi.searchNewsListPage(
        pageNumber,
        searchTerm: searchTerm,
      );

      final isFiltering = searchTerm.isNotEmpty;

      // Enhanced: Cache everything, including search results
      // This follows the principle of aggressive caching for better UX
      final shouldStoreOnCache = true; // Cache everything!

      if (shouldStoreOnCache) {
        // Only clear cache for non-search first page requests
        final shouldEmptyCache = pageNumber == 1 && !isFiltering;
        if (shouldEmptyCache) {
          await _localStorage.clearAllCachedNews();
        }

        final cachePage = apiPage.toCacheModel();

        // Enhanced: Mark search results and paginated content appropriately
        if (isFiltering) {
          // Mark as temporary search results for later cleanup
          final tempCachePage = cachePage
              .map((article) => article.copyWith(isTemp: true))
              .toList();
          await _localStorage.upsertNewsListPage(tempCachePage);
        } else {
          // Regular content, append for pagination
          await _localStorage.upsertNewsListPage(cachePage);
        }
      }

      final domainPage = apiPage.toDomainModel();
      return domainPage;
    } on EmptySearchResultNewsApiException catch (_) {
      throw EmptySearchResultException();
    }
  }

  Future<Article?> getArticleByTitle(String title) async {
    final cachedArticle = await _localStorage.getArticleByTitle(title);
    return cachedArticle?.toDomainModel();
  }

  // Enhanced: Add method to clear search cache periodically
  Future<void> clearSearchCache() async {
    await _localStorage.clearTempCachedNews();
  }

  Future<void> clearCache() async {
    await _localStorage.clearAllCachedNews();
  }
}

enum NewsListPageFetchPolicy {
  cacheAndNetwork,
  networkOnly,
  networkPreferably,
  cachePreferably,
}
