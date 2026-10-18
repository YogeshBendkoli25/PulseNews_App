import 'package:dio/dio.dart';
import 'package:traker_task/core/constants/api_constants.dart';
import 'package:traker_task/core/error/exceptions.dart';
import 'package:traker_task/features/news/data/models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getTopHeadlines({int page = 1});

  Future<List<ArticleModel>> searchNews(
    String query, {
    int page = 1,
  });
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ArticleModel>> getTopHeadlines({int page = 1}) async {
    try {
      final offset = (page - 1) * ApiConstants.defaultPageSize;
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.articlesEndpoint}',
        queryParameters: {
          'limit': ApiConstants.defaultPageSize,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> results =
            (response.data['results'] as List<dynamic>?) ?? [];
        return results
            .map((json) => ArticleModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch headlines from server',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (dioError) {
      throw ServerException(
        message: dioError.message ?? 'Network error while contacting news service',
        statusCode: dioError.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<ArticleModel>> searchNews(
    String query, {
    int page = 1,
  }) async {
    try {
      final offset = (page - 1) * ApiConstants.defaultPageSize;
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.articlesEndpoint}',
        queryParameters: {
          'search': query,
          'limit': ApiConstants.defaultPageSize,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> results =
            (response.data['results'] as List<dynamic>?) ?? [];
        return results
            .map((json) => ArticleModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to search news',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (dioError) {
      throw ServerException(
        message: dioError.message ?? 'Network error while searching news',
        statusCode: dioError.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
