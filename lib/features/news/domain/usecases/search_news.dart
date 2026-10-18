import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/domain/repositories/news_repository.dart';

class SearchNews {
  final NewsRepository repository;

  SearchNews(this.repository);

  Future<List<Article>> call(String query, {int page = 1}) async {
    return await repository.searchNews(query, page: page);
  }
}
