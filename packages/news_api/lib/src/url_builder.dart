class UrlBuilder {
  const UrlBuilder({
    String? baseUrl,
  }) : _baseUrl = baseUrl ?? 'https://newsapi.org/v2';

  final String _baseUrl;

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

    final queryParams = <String, String>{
      'q': query,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    // Add optional parameters if they are provided
    if (sources != null && sources.isNotEmpty) {
      queryParams['sources'] = sources;
    }

    if (domains != null && domains.isNotEmpty) {
      queryParams['domains'] = domains;
    }

    if (excludeDomains != null && excludeDomains.isNotEmpty) {
      queryParams['excludeDomains'] = excludeDomains;
    }

    if (from != null && from.isNotEmpty) {
      queryParams['from'] = from;
    }

    if (to != null && to.isNotEmpty) {
      queryParams['to'] = to;
    }

    if (language != null && language.isNotEmpty) {
      queryParams['language'] = language;
    }

    if (sortBy != null && sortBy.isNotEmpty) {
      queryParams['sortBy'] = sortBy;
    }

    // Build query string
    final queryString = queryParams.entries
        .map((entry) =>
            '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    return '$_baseUrl/everything?$queryString';
  }
}
