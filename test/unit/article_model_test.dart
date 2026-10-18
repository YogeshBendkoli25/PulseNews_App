import 'package:flutter_test/flutter_test.dart';
import 'package:traker_task/features/news/data/models/article_model.dart';
import 'package:traker_task/features/news/domain/entities/article.dart';

void main() {
  group('ArticleModel Test Suite', () {
    const testArticleModel = ArticleModel(
      title: 'Breaking Tech News',
      description: 'Exciting AI announcement',
      content: 'Full story about AI advances',
      url: 'https://example.com/tech-news',
      urlToImage: 'https://example.com/image.png',
      publishedAt: '2026-10-18T10:00:00Z',
      author: 'Tech Reporter',
      sourceName: 'Daily Tech',
    );

    test('should be a subclass of Article entity', () {
      expect(testArticleModel, isA<Article>());
    });

    test('fromJson should return valid model from complete JSON map', () {
      final jsonMap = {
        'title': 'Breaking Tech News',
        'description': 'Exciting AI announcement',
        'content': 'Full story about AI advances',
        'url': 'https://example.com/tech-news',
        'urlToImage': 'https://example.com/image.png',
        'publishedAt': '2026-10-18T10:00:00Z',
        'author': 'Tech Reporter',
        'source': {'id': 'tech-id', 'name': 'Daily Tech'},
      };

      final result = ArticleModel.fromJson(jsonMap);

      expect(result.title, 'Breaking Tech News');
      expect(result.author, 'Tech Reporter');
      expect(result.sourceName, 'Daily Tech');
      expect(result.url, 'https://example.com/tech-news');
    });

    test('fromJson should parse real news API schema correctly', () {
      final realApiJson = {
        'id': 40424,
        'title': 'Eagle Nebula Pillars Sonified',
        'authors': [{'name': 'NASA'}],
        'url': 'https://science.nasa.gov/article/1',
        'image_url': 'https://example.com/eagle.jpg',
        'news_site': 'NASA Science',
        'summary': 'Detailed breakdown of the Eagle Nebula',
        'published_at': '2026-10-18T04:05:00Z',
      };

      final result = ArticleModel.fromJson(realApiJson);

      expect(result.title, 'Eagle Nebula Pillars Sonified');
      expect(result.author, 'NASA');
      expect(result.sourceName, 'NASA Science');
      expect(result.urlToImage, 'https://example.com/eagle.jpg');
      expect(result.description, 'Detailed breakdown of the Eagle Nebula');
      expect(result.publishedAt, '2026-10-18T04:05:00Z');
    });

    test('fromJson should handle null and missing fields gracefully', () {
      final jsonMap = <String, dynamic>{
        'url': 'https://example.com/news',
      };

      final result = ArticleModel.fromJson(jsonMap);

      expect(result.title, 'Untitled Article');
      expect(result.description, isNull);
      expect(result.author, isNull);
      expect(result.urlToImage, isNull);
      expect(result.url, 'https://example.com/news');
    });

    test('toJson should return Map containing proper key-values', () {
      final json = testArticleModel.toJson();

      expect(json['title'], 'Breaking Tech News');
      expect(json['description'], 'Exciting AI announcement');
      expect(json['url'], 'https://example.com/tech-news');
      expect(json['author'], 'Tech Reporter');
      expect(json['sourceName'], 'Daily Tech');
    });

    test('toEntity and fromEntity should preserve data parity', () {
      final entity = testArticleModel.toEntity();
      final fromEntity = ArticleModel.fromEntity(entity);

      expect(fromEntity, equals(testArticleModel));
    });
  });
}
