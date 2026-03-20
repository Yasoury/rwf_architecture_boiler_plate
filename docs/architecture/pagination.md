# Pagination

## Data Flow

1. State manager requests page N with a fetch policy
2. Repository returns `Stream<QuoteListPage>` (may emit cached then fresh)
3. `QuoteListPage` contains `quoteList` (items) and `isLastPage` (boolean)
4. State manager appends items for subsequent pages, replaces for refresh
5. UI uses `infinite_scroll_pagination` package for infinite scroll

## Pagination State in Bloc

```dart
class QuoteListState extends Equatable {
  const QuoteListState({
    this.quotes = const [],
    this.nextPage = 1,
    this.filter,
    this.searchTerm = '',
    this.isLoading = false,
    this.error,
  });

  final List<Quote> quotes;
  final int? nextPage;  // null = no more pages
  final Tag? filter;
  final String searchTerm;
  final bool isLoading;
  final dynamic error;
}
```

## Page Loading Rules

- `pageNumber == 1` → clear existing list, show loading indicator
- `pageNumber > 1` → append to existing list, show loading at bottom
- `isLastPage == true` → set `nextPage` to null, stop requesting
- Pull-to-refresh → reset to page 1 with `networkOnly` policy
