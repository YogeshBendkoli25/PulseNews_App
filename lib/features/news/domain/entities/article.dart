import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? author;
  final String? sourceName;

  const Article({
    required this.title,
    this.description,
    this.content,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.author,
    this.sourceName,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        content,
        url,
        urlToImage,
        publishedAt,
        author,
        sourceName,
      ];
}
