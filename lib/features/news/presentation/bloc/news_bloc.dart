import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traker_task/core/network/network_info.dart';
import 'package:traker_task/features/news/domain/usecases/get_cached_news.dart';
import 'package:traker_task/features/news/domain/usecases/get_top_headlines.dart';
import 'package:traker_task/features/news/domain/usecases/search_news.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetTopHeadlines getTopHeadlines;
  final SearchNews searchNews;
  final GetCachedNews getCachedNews;
  final NetworkInfo networkInfo;

  NewsBloc({
    required this.getTopHeadlines,
    required this.searchNews,
    required this.getCachedNews,
    required this.networkInfo,
  }) : super(NewsInitial()) {
    on<FetchHeadlinesEvent>(_onFetchHeadlines);
    on<LoadMoreHeadlinesEvent>(_onLoadMoreHeadlines);
    on<SearchNewsEvent>(_onSearchNews);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onFetchHeadlines(
    FetchHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    if (!event.isRefresh && state is! NewsLoaded) {
      emit(NewsLoading());
    }

    final isConnected = await networkInfo.isConnected;

    try {
      final articles = await getTopHeadlines(
        page: 1,
        forceRefresh: event.isRefresh,
      );

      if (articles.isEmpty) {
        emit(const NewsEmpty(message: 'No articles available at this moment.'));
      } else {
        emit(NewsLoaded(
          articles: articles,
          currentPage: 1,
          hasReachedMax: false,
          isOffline: !isConnected,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      try {
        final cachedArticles = await getCachedNews();
        if (cachedArticles.isNotEmpty) {
          emit(NewsLoaded(
            articles: cachedArticles,
            currentPage: 1,
            hasReachedMax: true,
            isOffline: true,
            isLoadingMore: false,
          ));
          return;
        }
      } catch (_) {}

      emit(NewsError(
        message: isConnected
            ? 'Failed to fetch news. Please check your connection or try again.'
            : 'You are offline and no cached articles are available.',
        isOffline: !isConnected,
      ));
    }
  }

  Future<void> _onLoadMoreHeadlines(
    LoadMoreHeadlinesEvent event,
    Emitter<NewsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NewsLoaded) return;
    if (currentState.hasReachedMax || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      emit(currentState.copyWith(isLoadingMore: false, hasReachedMax: true));
      return;
    }

    try {
      final isSearching =
          currentState.searchQuery != null && currentState.searchQuery!.isNotEmpty;

      final newArticles = isSearching
          ? await searchNews(currentState.searchQuery!, page: nextPage)
          : await getTopHeadlines(page: nextPage);

      if (newArticles.isEmpty) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          hasReachedMax: true,
        ));
      } else {
        emit(currentState.copyWith(
          articles: [...currentState.articles, ...newArticles],
          currentPage: nextPage,
          isLoadingMore: false,
          hasReachedMax: false,
        ));
      }
    } catch (_) {
      emit(currentState.copyWith(
        isLoadingMore: false,
        hasReachedMax: true,
      ));
    }
  }

  Future<void> _onSearchNews(
    SearchNewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const FetchHeadlinesEvent());
      return;
    }

    emit(NewsLoading());

    final isConnected = await networkInfo.isConnected;

    try {
      final results = await searchNews(query, page: 1);

      if (results.isEmpty) {
        emit(NewsEmpty(message: 'No articles found matching "$query"'));
      } else {
        emit(NewsLoaded(
          articles: results,
          currentPage: 1,
          hasReachedMax: false,
          isOffline: !isConnected,
          isLoadingMore: false,
          searchQuery: query,
        ));
      }
    } catch (e) {
      emit(NewsError(
        message: 'Unable to perform search. Please try again.',
        isOffline: !isConnected,
      ));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<NewsState> emit) {
    add(const FetchHeadlinesEvent());
  }
}
