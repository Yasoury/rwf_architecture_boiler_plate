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
    final shouldSkipCacheLookup = isSearching || isFetchPolicyNetworkOnly;

    if (shouldSkipCacheLookup) {
      final freshPage = await _getNewsListPageFromNetwork(
        pageNumber,
        searchTerm,
      );

      yield freshPage;
    } else {
      final cachedArticles = await _localStorage.getArticles();

      final isFetchPolicyCacheAndNetwork =
          fetchPolicy == NewsListPageFetchPolicy.cacheAndNetwork;

      final isFetchPolicyCachePreferably =
          fetchPolicy == NewsListPageFetchPolicy.cachePreferably;

      final shouldEmitCachedPageInAdvance =
          isFetchPolicyCachePreferably || isFetchPolicyCacheAndNetwork;

      if (shouldEmitCachedPageInAdvance && cachedArticles.isNotEmpty) {
        yield NewsListPage(
          articles: cachedArticles.toDomainModel(),
        );
        if (isFetchPolicyCachePreferably) {
          return;
        }
      }

      try {
        final freshPage = await _getNewsListPageFromNetwork(
          pageNumber,
          searchTerm,
        );

        yield freshPage;
      } catch (_) {
        final isFetchPolicyNetworkPreferably =
            fetchPolicy == NewsListPageFetchPolicy.networkPreferably;
        if (cachedArticles.isNotEmpty && isFetchPolicyNetworkPreferably) {
          yield NewsListPage(
            articles: cachedArticles.toDomainModel(),
          );
          return;
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

      final shouldStoreOnCache = !isFiltering;
      if (shouldStoreOnCache) {
        final shouldEmptyCache = pageNumber == 1;
        if (shouldEmptyCache) {
          await _localStorage.clearAllCachedNews();
        }

        final cachePage = apiPage.toCacheModel();
        await _localStorage.upsertNewsListPage(
          cachePage,
        );
      }

      final domainPage = apiPage.toDomainModel();
      return domainPage;
    } on EmptySearchResultNewsApiException catch (_) {
      throw EmptySearchResultException();
    }
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
