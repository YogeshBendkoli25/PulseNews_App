import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/domain/repositories/news_repository.dart';

class GetTopHeadlines {
  final NewsRepository repository;

  GetTopHeadlines(this.repository);

  Future<List<Article>> call({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return await repository.getTopHeadlines(
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
