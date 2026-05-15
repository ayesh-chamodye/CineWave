part of 'tv_detail_bloc.dart';

abstract class TVDetailEvent extends Equatable {
  const TVDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadTVDetail extends TVDetailEvent {
  final TVShow tvShow;

  const LoadTVDetail({required this.tvShow});

  @override
  List<Object> get props => [tvShow];
}