import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traker_task/core/theme/bloc/theme_bloc.dart';
import 'package:traker_task/features/news/data/datasources/news_local_data_source.dart';
import 'package:traker_task/features/news/data/datasources/news_remote_data_source.dart';
import 'package:traker_task/features/news/data/repositories/news_repository_impl.dart';
import 'package:traker_task/features/news/domain/repositories/news_repository.dart';
import 'package:traker_task/features/news/domain/usecases/get_cached_news.dart';
import 'package:traker_task/features/news/domain/usecases/get_top_headlines.dart';
import 'package:traker_task/features/news/domain/usecases/search_news.dart';
import 'package:traker_task/features/news/presentation/bloc/news_bloc.dart';

import 'network/network_info.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  await Hive.initFlutter();
  final newsBox = await Hive.openBox(NewsLocalDataSourceImpl.boxName);
  sl.registerLazySingleton<Box>(() => newsBox);

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  sl.registerLazySingleton<Dio>(() => dio);

  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(box: sl()),
  );

  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetTopHeadlines(sl()));
  sl.registerLazySingleton(() => SearchNews(sl()));
  sl.registerLazySingleton(() => GetCachedNews(sl()));

  sl.registerFactory(
    () => NewsBloc(
      getTopHeadlines: sl(),
      searchNews: sl(),
      getCachedNews: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));
}
