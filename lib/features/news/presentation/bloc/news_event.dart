import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class FetchHeadlinesEvent extends NewsEvent {
  final bool isRefresh;

  const FetchHeadlinesEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreHeadlinesEvent extends NewsEvent {}

class SearchNewsEvent extends NewsEvent {
  final String query;

  const SearchNewsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends NewsEvent {}
