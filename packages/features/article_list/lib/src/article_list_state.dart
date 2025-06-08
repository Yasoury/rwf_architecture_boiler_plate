part of 'article_list_bloc.dart';

class ArticleListState extends Equatable {
  const ArticleListState({
    this.itemList,
    this.nextPage,
    this.error,
    this.filter,
    this.refreshError,
    this.viewMode = ArticleViewMode.grid,
  });

  final List<Article>? itemList;
  final int? nextPage;
  final dynamic error;
  final ArticleListFilter? filter;
  final dynamic refreshError;
  final ArticleViewMode viewMode;

  // Keep existing viewMode unless explicitly changed
  ArticleListState.loadingNewTag({
    required Tag? tag,
    ArticleListState? previousState,
  }) : this(
          filter: tag != null ? ArticleListFilterByTag(tag) : null,
          viewMode: previousState?.viewMode ?? ArticleViewMode.grid,
        );

  ArticleListState.loadingNewSearchTerm({
    required String searchTerm,
    ArticleListState? previousState,
  }) : this(
          filter: searchTerm.isEmpty
              ? null
              : ArticleListFilterBySearchTerm(searchTerm),
          viewMode: previousState?.viewMode ?? ArticleViewMode.grid,
        );

  ArticleListState.noItemsFound({
    required ArticleListFilter? filter,
    ArticleListState? previousState,
  }) : this(
          itemList: const [],
          error: null,
          nextPage: 1,
          filter: filter,
          viewMode: previousState?.viewMode ?? ArticleViewMode.grid,
        );

  ArticleListState.success({
    required int? nextPage,
    required List<Article> itemList,
    required ArticleListFilter? filter,
    required bool isRefresh,
    ArticleListState? previousState,
  }) : this(
          nextPage: nextPage,
          itemList: itemList,
          filter: filter,
          viewMode: previousState?.viewMode ?? ArticleViewMode.grid,
        );

  // Copy methods preserve viewMode automatically
  ArticleListState copyWithNewError(dynamic error) => ArticleListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: null,
        viewMode: viewMode,
      );

  ArticleListState copyWithNewRefreshError(dynamic refreshError) =>
      ArticleListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: refreshError,
        viewMode: viewMode,
      );

  ArticleListState copyWithViewMode(ArticleViewMode newViewMode) {
    return ArticleListState(
      itemList: itemList,
      nextPage: nextPage,
      error: error,
      filter: filter,
      refreshError: refreshError,
      viewMode: newViewMode,
    );
  }

  @override
  List<Object?> get props => [
        itemList,
        nextPage,
        error,
        filter,
        refreshError,
        viewMode,
      ];
}

abstract class ArticleListFilter extends Equatable {
  const ArticleListFilter();

  @override
  List<Object?> get props => [];
}

class ArticleListFilterByTag extends ArticleListFilter {
  const ArticleListFilterByTag(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [
        tag,
      ];
}

class ArticleListFilterBySearchTerm extends ArticleListFilter {
  const ArticleListFilterBySearchTerm(this.searchTerm);

  final String searchTerm;

  @override
  List<Object?> get props => [
        searchTerm,
      ];
}

enum ArticleViewMode { grid, list }
