import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final int currentPage;
  final bool hasReachedMax;
  final bool isOffline;
  final bool isLoadingMore;
  final String? searchQuery;

  const NewsLoaded({
    required this.articles,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.isOffline = false,
    this.isLoadingMore = false,
    this.searchQuery,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    int? currentPage,
    bool? hasReachedMax,
    bool? isOffline,
    bool? isLoadingMore,
    String? searchQuery,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isOffline: isOffline ?? this.isOffline,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        articles,
        currentPage,
        hasReachedMax,
        isOffline,
        isLoadingMore,
        searchQuery,
      ];
}

class NewsEmpty extends NewsState {
  final String message;

  const NewsEmpty({this.message = 'No articles found matching your criteria.'});

  @override
  List<Object?> get props => [message];
}

class NewsError extends NewsState {
  final String message;
  final bool isOffline;

  const NewsError({
    required this.message,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [message, isOffline];
}
