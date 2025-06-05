class UrlBuilder {
  const UrlBuilder();

  static const _baseUrl = 'https://newsapi.org/v2';

  // Existing everything endpoint
  String buildGetEverythingUrl({
    required String query,
    int page = 1,
    int pageSize = 10,
    String? sources,
    String? domains,
    String? excludeDomains,
    String? from,
    String? to,
    String? language,
    String? sortBy,
  }) {
    assert(query.isNotEmpty, 'Query parameter cannot be empty');
    assert(page > 0, 'Page must be greater than 0');
    assert(
        pageSize > 0 && pageSize <= 100, 'Page size must be between 1 and 100');

    final uri = Uri.parse(_baseUrl).replace(
      path: '/everything',
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (sources != null && sources.isNotEmpty) 'sources': sources,
        if (domains != null && domains.isNotEmpty) 'domains': domains,
        if (excludeDomains != null && excludeDomains.isNotEmpty)
          'excludeDomains': excludeDomains,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (language != null && language.isNotEmpty) 'language': language,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      },
    );

    return uri.toString();
  }

  // New top-headlines endpoint
  String buildGetTopHeadlinesUrl({
    String? country = 'us',
    String? category,
    String? sources,
    String? query,
    int pageSize = 10,
    int page = 1,
  }) {
    // Validation following NewsAPI constraints
    assert(page > 0, 'Page must be greater than 0');
    assert(
        pageSize > 0 && pageSize <= 100, 'Page size must be between 1 and 100');
    assert(
        (country != null && sources == null) ||
            (sources != null && country == null) ||
            (country == null && sources == null),
        'Cannot mix country and sources parameters');
    assert(
        (category != null && sources == null) ||
            (sources != null && category == null) ||
            (category == null && sources == null),
        'Cannot mix category and sources parameters');

    final uri = Uri.parse(_baseUrl).replace(
      path: '/top-headlines',
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (country != null && country.isNotEmpty) 'country': country,
        if (category != null && category.isNotEmpty) 'category': category,
        if (sources != null && sources.isNotEmpty) 'sources': sources,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );

    return uri.toString();
  }
}
