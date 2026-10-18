import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traker_task/features/news/domain/entities/article.dart';
import 'package:traker_task/features/news/presentation/pages/article_detail_page.dart';
import 'package:traker_task/features/news/presentation/widgets/animated_connectivity_snackbar.dart';
import 'package:traker_task/features/news/presentation/widgets/article_card.dart';
import 'package:traker_task/features/news/presentation/widgets/empty_or_error_view.dart';
import 'package:traker_task/features/news/presentation/widgets/offline_status_banner.dart';
import 'package:traker_task/features/splash/presentation/pages/splash_page.dart';
import 'package:traker_task/features/splash/presentation/widgets/brand_title.dart';
import 'package:traker_task/features/splash/presentation/widgets/pulse_logo.dart';

void main() {
  group('Widget Tests', () {
    const testArticle = Article(
      title: 'Revolutionary Tech Milestone 2026',
      description: 'Major breakthrough in computational science.',
      content: 'Detailed article contents here.',
      url: 'https://example.com/milestone',
      publishedAt: '2026-10-18T09:00:00Z',
      author: 'Jane Doe',
      sourceName: 'TechDaily',
    );

    testWidgets('ArticleCard renders title, source, author and handles tap',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: testArticle,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Revolutionary Tech Milestone 2026'), findsOneWidget);

      // Verify source tag is rendered
      expect(find.text('TechDaily'), findsOneWidget);

      // Verify author is rendered
      expect(find.text('By Jane Doe'), findsOneWidget);

      // Verify tap works
      await tester.tap(find.byType(ArticleCard));
      expect(tapped, isTrue);
    });

    testWidgets('OfflineStatusBanner renders offline label and triggers retry',
        (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineStatusBanner(
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Offline Mode: Viewing cached articles'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('AnimatedConnectivitySnackBarContent renders online state with wifi icon and text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedConnectivitySnackBarContent(isOnline: true),
          ),
        ),
      );

      expect(find.text('You are online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    });

    testWidgets('AnimatedConnectivitySnackBarContent renders offline state with wifi_off icon and text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedConnectivitySnackBarContent(isOnline: false),
          ),
        ),
      );

      expect(find.text('You are offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('SplashPage renders branding and version watermark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(find.text('Live Stories • Global Perspectives'), findsOneWidget);
      expect(find.text('v1.0.0'), findsOneWidget);
    });

    testWidgets('PulseLogo renders with specified size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PulseLogo(size: 48, borderRadius: 12),
          ),
        ),
      );

      expect(find.byType(PulseLogo), findsOneWidget);
    });

    testWidgets('BrandTitle renders title and custom tagline',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrandTitle(tagline: 'Custom Tagline'),
          ),
        ),
      );

      expect(find.text('Custom Tagline'), findsOneWidget);
    });

    testWidgets('ArticleCard renders without overflow on ultra-narrow 300px screen with long source name',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const longSourceArticle = Article(
        title: 'Tech Breakthrough Across Global Research Labs',
        description: 'Comprehensive analysis of groundbreaking research.',
        url: 'https://example.com/breakthrough',
        publishedAt: '2026-10-18T12:00:00Z',
        author: 'Senior Technology Correspondent Jane Doe',
        sourceName: 'The International Wall Street Financial & Technology Journal',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ArticleCard(
              article: longSourceArticle,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ArticleCard), findsOneWidget);
    });

    testWidgets('EmptyOrErrorView renders without overflow in compact landscape 600x280 mode',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(600, 280);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyOrErrorView(
              icon: Icons.error_outline_rounded,
              title: 'Unable to Load News',
              message: 'Check your internet connection and tap retry below to reload.',
              buttonText: 'Try Again',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Unable to Load News'), findsOneWidget);
    });

    testWidgets('SplashPage renders cleanly in landscape orientation',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(700, 340);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Live Stories • Global Perspectives'), findsOneWidget);
    });
  });
}
