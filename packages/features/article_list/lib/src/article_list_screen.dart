import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:article_list/src/filter_horizontal_list.dart';
import 'package:article_list/src/l10n/article_list_localizations.dart';
import 'package:article_list/src/article_list_bloc.dart';
import 'package:article_list/src/article_paged_grid_view.dart';
import 'package:article_list/src/article_paged_list_view.dart';
import 'package:news_repository/news_repository.dart';

typedef ArticleSelected = Function(String selectedArticle);

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({
    required this.newsRepository,
    this.onArticleSelected,
    super.key,
  });

  final NewsRepository newsRepository;

  final ArticleSelected? onArticleSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ArticleListBloc>(
      create: (_) => ArticleListBloc(
        newsRepository: newsRepository,
      ),
      child: ArticleListView(
        onArticleSelected: onArticleSelected,
      ),
    );
  }
}

@visibleForTesting
class ArticleListView extends StatefulWidget {
  const ArticleListView({
    this.onArticleSelected,
    super.key,
  });

  final ArticleSelected? onArticleSelected;

  @override
  ArticleListViewState createState() => ArticleListViewState();
}

class ArticleListViewState extends State<ArticleListView> {
  // For a deep dive on PagingController refer to: https://www.raywenderlich.com/14214369-infinite-scrolling-pagination-in-flutter
  final PagingController<int, Article> _pagingController = PagingController(
    firstPageKey: 1,
  );

  final TextEditingController _searchBarController = TextEditingController();

  ArticleListBloc get _bloc => context.read<ArticleListBloc>();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageNumber) {
      final isSubsequentPage = pageNumber > 1;
      if (isSubsequentPage) {
        _bloc.add(
          ArticleListNextPageRequested(
            pageNumber: pageNumber,
          ),
        );
      }
    });

    _searchBarController.addListener(() {
      _bloc.add(
        ArticleListSearchTermChanged(
          _searchBarController.text,
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final l10n = ArticleListLocalizations.of(context);
    return BlocListener<ArticleListBloc, ArticleListState>(
      listener: (context, state) {
        final searchBarText = _searchBarController.text;
        final isSearching = state.filter != null &&
            state.filter is ArticleListFilterBySearchTerm;
        if (searchBarText.isNotEmpty && !isSearching) {
          _searchBarController.text = '';
        }

        if (state.refreshError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.newsRefreshErrorMessage,
              ),
            ),
          );
        }
        _pagingController.value = state.toPagingState();
      },
      child: StyledStatusBar.dark(
        child: SafeArea(
          child: Scaffold(
            body: GestureDetector(
              onTap: () => _releaseFocus(context),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.screenMargin,
                    ),
                    child: CustomSearchBar(
                      controller: _searchBarController,
                    ),
                  ),
                  const FilterHorizontalList(),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () {
                        _bloc.add(
                          const ArticleListRefreshed(),
                        );

                        // Returning a Future inside `onRefresh` enables the loading
                        // indicator to disappear automatically once the refresh is
                        // complete.
                        final stateChangeFuture = _bloc.stream.first;
                        return stateChangeFuture;
                      },
                      child: 1 == 1 //TODO
                          ? ArticlePagedGridView(
                              pagingController: _pagingController,
                              onArticleSelected: widget.onArticleSelected,
                            )
                          : ArticlePagedListView(
                              pagingController: _pagingController,
                              onArticleSelected: widget.onArticleSelected,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _releaseFocus(BuildContext context) => FocusScope.of(
        context,
      ).unfocus();

  @override
  void dispose() {
    _pagingController.dispose();
    _searchBarController.dispose();
    super.dispose();
  }
}

extension on ArticleListState {
  PagingState<int, Article> toPagingState() {
    return PagingState(
      itemList: itemList,
      nextPageKey: nextPage,
      error: error,
    );
  }
}
