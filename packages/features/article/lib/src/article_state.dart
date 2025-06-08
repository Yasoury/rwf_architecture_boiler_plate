part of 'article_cubit.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();

  @override
  List<Object?> get props => [];
}

class ArticleInProgress extends ArticleState {
  const ArticleInProgress();
}

class ArticleLoaded extends ArticleState {
  const ArticleLoaded({
    required this.article,
  });

  final Article article;

  @override
  List<Object?> get props => [article];
}

class ArticleFailure extends ArticleState {
  const ArticleFailure({
    this.error,
  });

  final String? error;

  @override
  List<Object?> get props => [error];
}
