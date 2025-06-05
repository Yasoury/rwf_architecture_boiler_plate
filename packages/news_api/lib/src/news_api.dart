import 'package:dio/dio.dart';
import 'package:news_api/src/models/exceptions.dart';
import 'package:news_api/src/models/models.dart';
import 'package:news_api/src/url_builder.dart';
import 'package:meta/meta.dart';

class NewsApi {
  NewsApi({
    @visibleForTesting Dio? dio,
    @visibleForTesting UrlBuilder? urlBuilder,
  })  : _dio = dio ?? Dio(),
        _urlBuilder = urlBuilder ?? const UrlBuilder() {
    _dio.setUpAuthHeaders();
    _dio.interceptors.add(
      LogInterceptor(responseBody: false),
    );
  }

  final Dio _dio;
  final UrlBuilder _urlBuilder;

  Future<NewsListPageRM> searchNewsListPage(
    int page, {
    String searchTerm = '',
    int pageSize = 10,
  }) async {
    final url = _urlBuilder.buildGetEverythingUrl(
      query: searchTerm,
      page: page,
      pageSize: pageSize,
    );

    try {
      final response = await _dio.get(url);
      final jsonObject = response.data;
      final newsListPage = NewsListPageRM.fromJson(jsonObject);

      if ((newsListPage.articles ?? []).isEmpty) {
        throw EmptySearchResultNewsApiException();
      }

      return newsListPage;
    } on DioException catch (dioException) {
      // Handle specific NewsAPI errors based on status codes
      switch (dioException.response?.statusCode) {
        case 401:
          throw InvalidApiKeyNewsApiException();
        case 429:
          throw RateLimitExceededNewsApiException();
        case 400:
          throw BadRequestNewsApiException();
        default:
          throw UnknownNewsApiException();
      }
    }
  }

  Future<NewsListPageRM> getTopHeadNewsListPage(
    int page, {
    int pageSize = 10,
  }) async {
    final url = _urlBuilder.buildGetTopHeadlinesUrl(
      page: page,
      pageSize: pageSize,
    );

    try {
      final response = await _dio.get(url);
      final jsonObject = response.data;
      final newsListPage = NewsListPageRM.fromJson(jsonObject);

      if ((newsListPage.articles ?? []).isEmpty) {
        throw EmptySearchResultNewsApiException();
      }

      return newsListPage;
    } on DioException catch (dioException) {
      // Handle specific NewsAPI errors based on status codes
      switch (dioException.response?.statusCode) {
        case 401:
          throw InvalidApiKeyNewsApiException();
        case 429:
          throw RateLimitExceededNewsApiException();
        case 400:
          throw BadRequestNewsApiException();
        default:
          throw UnknownNewsApiException();
      }
    }
  }

  Future<NewsListPageRM> getNewsListPage(
    int page, {
    String searchTerm = '',
    int pageSize = 10,
  }) async {
    final url = _urlBuilder.buildGetEverythingUrl(
      query: searchTerm,
      page: page,
      pageSize: pageSize,
    );

    try {
      final response = await _dio.get(url);
      final jsonObject = response.data;
      final newsListPage = NewsListPageRM.fromJson(jsonObject);

      if ((newsListPage.articles ?? []).isEmpty) {
        throw EmptySearchResultNewsApiException();
      }

      return newsListPage;
    } on DioException catch (dioException) {
      // Handle specific NewsAPI errors based on status codes
      switch (dioException.response?.statusCode) {
        case 401:
          throw InvalidApiKeyNewsApiException();
        case 429:
          throw RateLimitExceededNewsApiException();
        case 400:
          throw BadRequestNewsApiException();
        default:
          throw UnknownNewsApiException();
      }
    }
  }
}

extension on Dio {
  static const _appTokenEnvironmentVariableKey = 'news-api-app-token';

  void setUpAuthHeaders() {
    final appToken = const String.fromEnvironment(
      _appTokenEnvironmentVariableKey,
    );

    assert(appToken.isNotEmpty,
        'News API token must be provided via --dart-define=news-api-app-token=YOUR_TOKEN');

    options = BaseOptions(
      headers: {
        'X-Api-Key': appToken,
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }
}
