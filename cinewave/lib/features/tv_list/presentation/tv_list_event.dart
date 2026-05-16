part of 'tv_list_bloc.dart';

abstract class TVListEvent extends Equatable {
  const TVListEvent();

  @override
  List<Object> get props => [];
}

class LoadTVPage extends TVListEvent {
  final int page;

  const LoadTVPage(this.page);

  @override
  List<Object> get props => [page];
}

class SearchTV extends TVListEvent {
  final String query;

  const SearchTV(this.query);

  @override
  List<Object> get props => [query];
}
