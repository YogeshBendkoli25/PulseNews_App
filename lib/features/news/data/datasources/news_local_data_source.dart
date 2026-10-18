import 'package:hive_flutter/hive_flutter.dart';
import 'package:traker_task/core/error/exceptions.dart';
import 'package:traker_task/features/news/data/models/article_model.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheArticles(List<ArticleModel> articles);
  Future<List<ArticleModel>> getLastArticles();
  Future<void> clearCache();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  static const String boxName = 'news_cache_box';
  static const String cacheKey = 'cached_articles';

  final Box box;

  NewsLocalDataSourceImpl({required this.box});

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    try {
      final List<Map<String, dynamic>> rawList =
          articles.map((article) => article.toJson()).toList();
      await box.put(cacheKey, rawList);
    } catch (e) {
      throw CacheException(message: 'Failed to cache articles: $e');
    }
  }

  @override
  Future<List<ArticleModel>> getLastArticles() async {
    try {
      final dynamic rawData = box.get(cacheKey);
      if (rawData != null && rawData is List) {
        return rawData.map<ArticleModel>((item) {
          final Map<String, dynamic> itemMap =
              Map<String, dynamic>.from(item as Map);
          return ArticleModel.fromJson(itemMap);
        }).toList();
      }
      return [];
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve cached articles: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.delete(cacheKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }
}
