import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:domain_models/domain_models.dart';
import 'package:news_repository/news_repository.dart';

part 'article_state.dart';

class ArticleCubit extends Cubit<ArticleState> {
  ArticleCubit({
    required this.newsRepository,
    required this.articleTitle,
  }) : super(const ArticleInProgress()) {
    onInit();
  }

  final NewsRepository newsRepository;
  final String articleTitle;

  void onInit() async {
    try {
      final article = await newsRepository.getArticleByTitle(articleTitle);

      if (article != null) {
        emit(ArticleLoaded(article: article));
      } else {
        emit(const ArticleFailure(error: 'Article not found'));
      }
    } catch (error) {
      emit(ArticleFailure(error: error.toString()));
    }
  }

  void retry() {
    onInit();
  }
}
