import 'package:traker_task/core/error/exceptions.dart';
import 'package:traker_task/core/network/network_info.dart';
import 'package:traker_task/features/news/data/datasources/news_local_data_source.dart';
import 'package:traker_task/features/news/data/datasources/news_remote_data_source.dart';
import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Article>> getTopHeadlines({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteArticles = await remoteDataSource.getTopHeadlines(
          page: page,
        );

        if (page == 1 && remoteArticles.isNotEmpty) {
          await localDataSource.cacheArticles(remoteArticles);
        }

        return remoteArticles.map((model) => model.toEntity()).toList();
      } catch (_) {
        final localArticles = await localDataSource.getLastArticles();
        if (localArticles.isNotEmpty) {
          return localArticles.map((model) => model.toEntity()).toList();
        }
        rethrow;
      }
    } else {
      final localArticles = await localDataSource.getLastArticles();
      if (localArticles.isNotEmpty) {
        return localArticles.map((model) => model.toEntity()).toList();
      } else {
        throw const NetworkException(
          message: 'No internet connection and no cached news found.',
        );
      }
    }
  }

  @override
  Future<List<Article>> searchNews(
    String query, {
    int page = 1,
  }) async {
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final searchResults = await remoteDataSource.searchNews(
          query,
          page: page,
        );
        return searchResults.map((model) => model.toEntity()).toList();
      } catch (_) {
        return _searchInCache(query);
      }
    } else {
      return _searchInCache(query);
    }
  }

  Future<List<Article>> _searchInCache(String query) async {
    final localArticles = await localDataSource.getLastArticles();
    final lowerQuery = query.toLowerCase();

    final filtered = localArticles.where((article) {
      final titleMatch = article.title.toLowerCase().contains(lowerQuery);
      final descMatch =
          article.description?.toLowerCase().contains(lowerQuery) ?? false;
      final contentMatch =
          article.content?.toLowerCase().contains(lowerQuery) ?? false;
      return titleMatch || descMatch || contentMatch;
    }).toList();

    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Article>> getCachedNews() async {
    final cached = await localDataSource.getLastArticles();
    return cached.map((model) => model.toEntity()).toList();
  }
}
