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

    final uri = Uri.parse('$_baseUrl/everything').replace(
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
}
