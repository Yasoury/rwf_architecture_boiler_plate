import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain_models/domain_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_repository/news_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'article_list_event.dart';

part 'article_list_state.dart';

class ArticleListBloc extends Bloc<ArticleListEvent, ArticleListState> {
  ArticleListBloc({
    required NewsRepository newsRepository,
  })  : _articleRepository = newsRepository,
        super(
          const ArticleListState(),
        ) {
    _registerEventsHandler();
    add(const ArticleListTagChanged(Tag.startups));
  }

  late final StreamSubscription _authChangesSubscription;

  final NewsRepository _articleRepository;

  void _registerEventsHandler() {
    on<ArticleListEvent>(
      (event, emitter) async {
        if (event is ArticleListFailedFetchRetried) {
          await _handleArticleListFailedFetchRetried(emitter);
        } else if (event is ArticleListTagChanged) {
          await _handleArticleListTagChanged(emitter, event);
        } else if (event is ArticleListSearchTermChanged) {
          await _handleArticleListSearchTermChanged(emitter, event);
        } else if (event is ArticleListRefreshed) {
          await _handleArticleListRefreshed(emitter, event);
        } else if (event is ArticleListNextPageRequested) {
          await _handleArticleListNextPageRequested(emitter, event);
        }
      },
      transformer: (eventStream, eventHandler) {
        final nonDebounceEventStream = eventStream.where(
          (event) => event is! ArticleListSearchTermChanged,
        );

        final debounceEventStream = eventStream
            .whereType<ArticleListSearchTermChanged>()
            .debounceTime(
              const Duration(seconds: 1),
            )
            .where((event) {
          final previousFilter = state.filter;
          final previousSearchTerm =
              previousFilter is ArticleListFilterBySearchTerm
                  ? previousFilter.searchTerm
                  : '';

          return event.searchTerm != previousSearchTerm;
        });

        final mergedEventStream = MergeStream([
          nonDebounceEventStream,
          debounceEventStream,
        ]);

        final restartableTransformer = restartable<ArticleListEvent>();
        return restartableTransformer(mergedEventStream, eventHandler);
      },
    );
  }

  Future<void> _handleArticleListFailedFetchRetried(Emitter emitter) {
    // Clears out the error and puts the loading indicator back on the screen.
    emitter(
      state.copyWithNewError(null),
    );

    final firstPageFetchStream = _fetchArticlePage(
      1,
      fetchPolicy: NewsListPageFetchPolicy.cacheAndNetwork,
    );

    return emitter.onEach<ArticleListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleArticleListTagChanged(
    Emitter emitter,
    ArticleListTagChanged event,
  ) {
    emitter(
      ArticleListState.loadingNewTag(tag: event.tag),
    );

    final firstPageFetchStream = _fetchArticlePage(
      1,
      // If the user is *deselecting* a tag, the `cachePreferably` fetch policy
      // will return you the cached articles. If the user is selecting a new tag
      // instead, the `cachePreferably` fetch policy won't find any cached
      // articles and will instead use the network.
      fetchPolicy: NewsListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<ArticleListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleArticleListSearchTermChanged(
    Emitter emitter,
    ArticleListSearchTermChanged event,
  ) {
    emitter(
      ArticleListState.loadingNewSearchTerm(
        searchTerm: event.searchTerm,
      ),
    );

    final firstPageFetchStream = _fetchArticlePage(
      1,
      // If the user is *clearing out* the search bar, the `cachePreferably`
      // fetch policy will return you the cached articles. If the user is
      // entering a new search instead, the `cachePreferably` fetch policy
      // won't find any cached articles and will instead use the network.
      fetchPolicy: NewsListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<ArticleListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleArticleListRefreshed(
    Emitter emitter,
    ArticleListRefreshed event,
  ) {
    final firstPageFetchStream = _fetchArticlePage(
      1,
      // Since the user is asking for a refresh, you don't want to get cached
      // articles, thus the `networkOnly` fetch policy makes the most sense.
      fetchPolicy: NewsListPageFetchPolicy.networkOnly,
      isRefresh: true,
    );

    return emitter.onEach<ArticleListState>(
      firstPageFetchStream,
      onData: emitter.call,
    );
  }

  Future<void> _handleArticleListNextPageRequested(
    Emitter emitter,
    ArticleListNextPageRequested event,
  ) {
    emitter(
      state.copyWithNewError(null),
    );

    final nextPageFetchStream = _fetchArticlePage(
      event.pageNumber,
      // The `networkPreferably` fetch policy prioritizes fetching the new page
      // from the server, and, if it fails, try grabbing it from the cache.
      fetchPolicy: NewsListPageFetchPolicy.networkPreferably,
    );

    return emitter.onEach<ArticleListState>(
      nextPageFetchStream,
      onData: emitter.call,
    );
  }

  Stream<ArticleListState> _fetchArticlePage(
    int page, {
    required NewsListPageFetchPolicy fetchPolicy,
    bool isRefresh = false,
  }) async* {
    final currentlyAppliedFilter = state.filter;

    final pagesStream = _articleRepository.getNewsListPage(
      page,
      currentlyAppliedFilter is ArticleListFilterBySearchTerm
          ? currentlyAppliedFilter.searchTerm
          : currentlyAppliedFilter is ArticleListFilterByTag
              ? currentlyAppliedFilter.tag.name
              : '',
      fetchPolicy: fetchPolicy,
    );

    try {
      await for (final newPage in pagesStream) {
        final newItemList = newPage.articles;
        final oldItemList = state.itemList ?? [];
        final completeItemList = isRefresh || page == 1
            ? newItemList
            : (oldItemList + (newItemList ?? []));

        final nextPage = /* newPage.isLastPage ? null : */ page + 1; //TODO

        yield ArticleListState.success(
          nextPage: nextPage,
          itemList: completeItemList ?? [],
          filter: currentlyAppliedFilter,
          isRefresh: isRefresh,
        );
      }
    } catch (error) {
      if (error is EmptySearchResultException) {
        yield ArticleListState.noItemsFound(
          filter: currentlyAppliedFilter,
        );
      }

      if (isRefresh) {
        yield state.copyWithNewRefreshError(
          error,
        );
      } else {
        yield state.copyWithNewError(
          error,
        );
      }
    }
  }

  @override
  Future<void> close() {
    _authChangesSubscription.cancel();
    return super.close();
  }
}
