
import 'package:traker_task/features/news/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.title,
    super.description,
    super.content,
    required super.url,
    super.urlToImage,
    required super.publishedAt,
    super.author,
    super.sourceName,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    String? author;
    if (json['authors'] != null &&
        json['authors'] is List &&
        (json['authors'] as List).isNotEmpty) {
      final firstAuthor = (json['authors'] as List).first;
      if (firstAuthor is Map && firstAuthor['name'] != null) {
        author = firstAuthor['name'].toString();
      }
    } else if (json['author'] != null) {
      author = json['author'].toString();
    }

    String? sourceName;
    if (json['news_site'] != null) {
      sourceName = json['news_site'].toString();
    } else if (json['source'] != null && json['source'] is Map) {
      sourceName = json['source']['name'] as String?;
    } else if (json['sourceName'] != null) {
      sourceName = json['sourceName'] as String?;
    }

    return ArticleModel(
      title: json['title'] as String? ?? 'Untitled Article',
      description: (json['summary'] ?? json['description']) as String?,
      content: (json['summary'] ?? json['content']) as String?,
      url: json['url'] as String? ?? '',
      urlToImage: (json['image_url'] ?? json['urlToImage']) as String?,
      publishedAt: (json['published_at'] ?? json['publishedAt']) as String? ??
          DateTime.now().toIso8601String(),
      author: author,
      sourceName: sourceName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'author': author,
      'sourceName': sourceName,
    };
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      title: article.title,
      description: article.description,
      content: article.content,
      url: article.url,
      urlToImage: article.urlToImage,
      publishedAt: article.publishedAt,
      author: article.author,
      sourceName: article.sourceName,
    );
  }

  Article toEntity() {
    return Article(
      title: title,
      description: description,
      content: content,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      author: author,
      sourceName: sourceName,
    );
  }
}
