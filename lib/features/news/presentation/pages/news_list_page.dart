import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traker_task/core/constants/app_colors.dart';
import 'package:traker_task/core/network/network_info.dart';
import 'package:traker_task/core/service_locator.dart' as di;
import 'package:traker_task/core/theme/bloc/theme_bloc.dart';
import 'package:traker_task/core/theme/bloc/theme_event.dart';
import 'package:traker_task/core/theme/bloc/theme_state.dart';
import 'package:traker_task/features/news/presentation/bloc/news_bloc.dart';
import 'package:traker_task/features/news/presentation/bloc/news_event.dart';
import 'package:traker_task/features/news/presentation/bloc/news_state.dart';
import 'package:traker_task/features/news/presentation/widgets/animated_connectivity_snackbar.dart';
import 'package:traker_task/features/news/presentation/widgets/article_card.dart';
import 'package:traker_task/features/news/presentation/widgets/empty_or_error_view.dart';
import 'package:traker_task/features/news/presentation/widgets/news_search_bar.dart';
import 'package:traker_task/features/news/presentation/widgets/news_shimmer_loading.dart';
import 'package:traker_task/features/news/presentation/widgets/offline_status_banner.dart';
import 'package:traker_task/features/splash/presentation/widgets/pulse_logo.dart';

import 'article_detail_page.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isSearchVisible = ValueNotifier<bool>(false);
  StreamSubscription<bool>? _connectivitySubscription;
  bool? _lastKnownOnlineStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NewsBloc>().add(const FetchHeadlinesEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConnectivityMonitoring();
    });
  }

  Future<void> _initConnectivityMonitoring() async {
    final networkInfo = di.sl<NetworkInfo>();
    final isOnline = await networkInfo.isConnected;
    if (!mounted) return;
    _lastKnownOnlineStatus = isOnline;
    showAnimatedConnectivitySnackBar(context, isOnline: isOnline);

    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isOnline,
    ) {
      if (!mounted) return;
      if (_lastKnownOnlineStatus != isOnline) {
        _lastKnownOnlineStatus = isOnline;
        showAnimatedConnectivitySnackBar(context, isOnline: isOnline);
        if (isOnline) {
          context.read<NewsBloc>().add(
            const FetchHeadlinesEvent(isRefresh: true),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _isSearchVisible.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context.read<NewsBloc>().add(LoadMoreHeadlinesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PulseLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 10),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pulse',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: 'News',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSearchVisible,
            builder: (context, isVisible, _) {
              return IconButton(
                icon: Icon(
                  isVisible ? Icons.search_off_rounded : Icons.search_rounded,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                tooltip: 'Search',
                onPressed: () {
                  _isSearchVisible.value = !isVisible;
                  if (isVisible) {
                    context.read<NewsBloc>().add(ClearSearchEvent());
                  }
                },
              );
            },
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      RotationTransition(turns: anim, child: child),
                  child: Icon(
                    themeState.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey<bool>(themeState.isDarkMode),
                    color: isDark
                        ? AppColors.warning
                        : AppColors.lightTextPrimary,
                  ),
                ),
                tooltip: 'Switch Theme',
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isSearchVisible,
                  builder: (context, isVisible, _) {
                    if (!isVisible) return const SizedBox.shrink();
                    return NewsSearchBar(
                      onSearch: (query) {
                        context.read<NewsBloc>().add(SearchNewsEvent(query));
                      },
                      onClear: () {
                        context.read<NewsBloc>().add(ClearSearchEvent());
                      },
                    );
                  },
                ),
                Expanded(
                  child: BlocBuilder<NewsBloc, NewsState>(
                    builder: (context, state) {
                      if (state is NewsLoading) {
                        return const SingleChildScrollView(
                          child: NewsShimmerLoading(),
                        );
                      } else if (state is NewsLoaded) {
                        return RefreshIndicator(
                          color: AppColors.primaryBlue,
                          onRefresh: () async {
                            context.read<NewsBloc>().add(
                              const FetchHeadlinesEvent(isRefresh: true),
                            );
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                        itemCount:
                            state.articles.length +
                            (state.isOffline ? 1 : 0) +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.isOffline) {
                            if (index == 0) {
                              return OfflineStatusBanner(
                                onRetry: () {
                                  context.read<NewsBloc>().add(
                                    const FetchHeadlinesEvent(isRefresh: true),
                                  );
                                },
                              );
                            }
                            index -= 1;
                          }

                          if (index >= state.articles.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            );
                          }

                          final article = state.articles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ArticleCard(
                              article: article,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ArticleDetailPage(article: article),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is NewsEmpty) {
                    return EmptyOrErrorView(
                      icon: Icons.search_off_rounded,
                      title: 'No Articles Found',
                      message: state.message,
                      buttonText: 'Reset Feed',
                      onAction: () {
                        context.read<NewsBloc>().add(
                          const FetchHeadlinesEvent(),
                        );
                      },
                    );
                  } else if (state is NewsError) {
                    return Column(
                      children: [
                        if (state.isOffline)
                          OfflineStatusBanner(
                            onRetry: () {
                              context.read<NewsBloc>().add(
                                const FetchHeadlinesEvent(),
                              );
                            },
                          ),
                        Expanded(
                          child: EmptyOrErrorView(
                            icon: state.isOffline
                                ? Icons.wifi_off_rounded
                                : Icons.error_outline_rounded,
                            title: state.isOffline
                                ? 'Connection Unavailable'
                                : 'Unable to Load News',
                            message: state.message,
                            buttonText: 'Try Again',
                            onAction: () {
                              context.read<NewsBloc>().add(
                                const FetchHeadlinesEvent(),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
