part of 'article_list_bloc.dart';

abstract class ArticleListEvent extends Equatable {
  const ArticleListEvent();

  @override
  List<Object?> get props => [];
}

class ArticleListTagChanged extends ArticleListEvent {
  const ArticleListTagChanged(
    this.tag,
  );

  final Tag? tag;

  @override
  List<Object?> get props => [
        tag,
      ];
}

class ArticleListSearchTermChanged extends ArticleListEvent {
  const ArticleListSearchTermChanged(
    this.searchTerm,
  );

  final String searchTerm;

  @override
  List<Object?> get props => [
        searchTerm,
      ];
}

class ArticleListRefreshed extends ArticleListEvent {
  const ArticleListRefreshed();
}

class ArticleListNextPageRequested extends ArticleListEvent {
  const ArticleListNextPageRequested({
    required this.pageNumber,
  });

  final int pageNumber;
}

class ArticleListFailedFetchRetried extends ArticleListEvent {
  const ArticleListFailedFetchRetried();
}

class ArticleListViewModeToggled extends ArticleListEvent {
  const ArticleListViewModeToggled();
}
