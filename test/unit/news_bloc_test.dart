import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:traker_task/core/network/network_info.dart';
import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/domain/usecases/get_cached_news.dart';
import 'package:traker_task/features/news/domain/usecases/get_top_headlines.dart';
import 'package:traker_task/features/news/domain/usecases/search_news.dart';
import 'package:traker_task/features/news/presentation/bloc/news_bloc.dart';
import 'package:traker_task/features/news/presentation/bloc/news_event.dart';
import 'package:traker_task/features/news/presentation/bloc/news_state.dart';

class MockGetTopHeadlines extends Mock implements GetTopHeadlines {}
class MockSearchNews extends Mock implements SearchNews {}
class MockGetCachedNews extends Mock implements GetCachedNews {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NewsBloc newsBloc;
  late MockGetTopHeadlines mockGetTopHeadlines;
  late MockSearchNews mockSearchNews;
  late MockGetCachedNews mockGetCachedNews;
  late MockNetworkInfo mockNetworkInfo;

  const testArticle = Article(
    title: 'Test Headline',
    description: 'Test description',
    content: 'Test content',
    url: 'https://example.com',
    urlToImage: 'https://example.com/image.png',
    publishedAt: '2026-10-18T10:00:00Z',
    author: 'Author',
    sourceName: 'Source',
  );

  final testArticles = [testArticle];

  setUp(() {
    mockGetTopHeadlines = MockGetTopHeadlines();
    mockSearchNews = MockSearchNews();
    mockGetCachedNews = MockGetCachedNews();
    mockNetworkInfo = MockNetworkInfo();

    newsBloc = NewsBloc(
      getTopHeadlines: mockGetTopHeadlines,
      searchNews: mockSearchNews,
      getCachedNews: mockGetCachedNews,
      networkInfo: mockNetworkInfo,
    );
  });

  tearDown(() {
    newsBloc.close();
  });

  group('NewsBloc Test Suite', () {
    test('initial state should be NewsInitial', () {
      expect(newsBloc.state, equals(NewsInitial()));
    });

    blocTest<NewsBloc, NewsState>(
      'emits [NewsLoading, NewsLoaded] when FetchHeadlinesEvent is successful and online',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockGetTopHeadlines(
              page: any(named: 'page'),
              forceRefresh: any(named: 'forceRefresh'),
            )).thenAnswer((_) async => testArticles);
        return newsBloc;
      },
      act: (bloc) => bloc.add(const FetchHeadlinesEvent()),
      expect: () => [
        NewsLoading(),
        NewsLoaded(
          articles: testArticles,
          currentPage: 1,
          hasReachedMax: false,
          isOffline: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockGetTopHeadlines(
              page: 1,
              forceRefresh: false,
            )).called(1);
      },
    );

    blocTest<NewsBloc, NewsState>(
      'emits [NewsLoading, NewsLoaded with isOffline=true] when offline but cached articles available',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockGetTopHeadlines(
              page: any(named: 'page'),
              forceRefresh: any(named: 'forceRefresh'),
            )).thenThrow(Exception('Offline'));
        when(() => mockGetCachedNews()).thenAnswer((_) async => testArticles);
        return newsBloc;
      },
      act: (bloc) => bloc.add(const FetchHeadlinesEvent()),
      expect: () => [
        NewsLoading(),
        NewsLoaded(
          articles: testArticles,
          currentPage: 1,
          hasReachedMax: true,
          isOffline: true,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<NewsBloc, NewsState>(
      'emits [NewsLoading, NewsLoaded] when SearchNewsEvent returns matching results',
      build: () {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockSearchNews('NASA', page: 1))
            .thenAnswer((_) async => testArticles);
        return newsBloc;
      },
      act: (bloc) => bloc.add(const SearchNewsEvent('NASA')),
      expect: () => [
        NewsLoading(),
        NewsLoaded(
          articles: testArticles,
          currentPage: 1,
          hasReachedMax: false,
          isOffline: false,
          isLoadingMore: false,
          searchQuery: 'NASA',
        ),
      ],
    );
  });
}
