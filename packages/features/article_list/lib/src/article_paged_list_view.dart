import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:article_list/article_list.dart';
import 'package:article_list/src/article_list_bloc.dart';

class ArticlePagedListView extends StatelessWidget {
  const ArticlePagedListView({
    required this.pagingController,
    this.onArticleSelected,
    super.key,
  });

  final PagingController<int, Article> pagingController;
  final ArticleSelected? onArticleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final onArticleSelected = this.onArticleSelected;
    final bloc = context.read<ArticleListBloc>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.screenMargin,
      ),
      child: PagedListView.separated(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Article>(
            itemBuilder: (context, article, index) {
              return ArticleCard(
                title: article.title ?? "",
                content: article.content ?? article.description ?? "",
                author: article.author,
                publishedAt: article.publishedAt,
                imageUrl: article.urlToImage,
                onTap: onArticleSelected != null
                    ? () async {
                        await onArticleSelected(article.title!);
                      }
                    : null,
              );
            },
            firstPageErrorIndicatorBuilder: (context) {
              return ExceptionIndicator(
                onTryAgain: () {
                  bloc.add(
                    const ArticleListFailedFetchRetried(),
                  );
                },
              );
            },
          ),
          separatorBuilder: (context, index) =>
              SizedBox(height: theme.gridSpacing)),
    );
  }
}
