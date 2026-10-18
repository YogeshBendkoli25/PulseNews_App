

import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/domain/repositories/news_repository.dart';

class GetCachedNews {
  final NewsRepository repository;

  GetCachedNews(this.repository);

  Future<List<Article>> call() async {
    return await repository.getCachedNews();
  }
}
