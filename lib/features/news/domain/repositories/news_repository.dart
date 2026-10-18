import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getTopHeadlines({
    int page = 1,
    bool forceRefresh = false,
  });

  Future<List<Article>> searchNews(
    String query, {
    int page = 1,
  });

  Future<List<Article>> getCachedNews();
}
