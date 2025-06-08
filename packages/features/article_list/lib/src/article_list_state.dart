part of 'article_list_bloc.dart';

class ArticleListState extends Equatable {
  const ArticleListState({
    this.itemList,
    this.nextPage,
    this.error,
    this.filter,
    this.refreshError,
  });

  final List<Article>? itemList;

  final int? nextPage;

  final dynamic error;

  final ArticleListFilter? filter;

  final dynamic refreshError;

  ArticleListState.loadingNewTag({
    required Tag? tag,
  }) : this(
          filter: tag != null ? ArticleListFilterByTag(tag) : null,
        );

  ArticleListState.loadingNewSearchTerm({
    required String searchTerm,
  }) : this(
          filter: searchTerm.isEmpty
              ? null
              : ArticleListFilterBySearchTerm(
                  searchTerm,
                ),
        );

  const ArticleListState.noItemsFound({
    required ArticleListFilter? filter,
  }) : this(
          itemList: const [],
          error: null,
          nextPage: 1,
          filter: filter,
        );

  const ArticleListState.success({
    required int? nextPage,
    required List<Article> itemList,
    required ArticleListFilter? filter,
    required bool isRefresh,
  }) : this(
          nextPage: nextPage,
          itemList: itemList,
          filter: filter,
        );

  ArticleListState copyWithNewError(
    dynamic error,
  ) =>
      ArticleListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: null,
      );

  ArticleListState copyWithNewRefreshError(
    dynamic refreshError,
  ) =>
      ArticleListState(
        itemList: itemList,
        nextPage: nextPage,
        error: error,
        filter: filter,
        refreshError: refreshError,
      );
  ArticleListState copyWithUpdatedArticle(
    Article updatedArticle,
  ) {
    return ArticleListState(
      itemList: itemList?.map((article) {
        if (article.title == updatedArticle.title) {
          return updatedArticle;
        } else {
          return article;
        }
      }).toList(),
      nextPage: nextPage,
      error: error,
      filter: filter,
      refreshError: null,
    );
  }

  @override
  List<Object?> get props => [
        itemList,
        nextPage,
        error,
        filter,
        refreshError,
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
