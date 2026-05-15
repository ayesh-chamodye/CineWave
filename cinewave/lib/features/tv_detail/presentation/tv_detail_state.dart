part of 'tv_detail_bloc.dart';

abstract class TVDetailState extends Equatable {
  const TVDetailState();

  @override
  List<Object> get props => [];
}

class TVDetailInitial extends TVDetailState {
  const TVDetailInitial();
}

class TVDetailLoading extends TVDetailState {
  const TVDetailLoading();
}

class TVDetailLoaded extends TVDetailState {
  final TVShow tvShow;

  const TVDetailLoaded({required this.tvShow});

  @override
  List<Object> get props => [tvShow];
}

class TVDetailError extends TVDetailState {
  final String message;

  const TVDetailError({required this.message});

  @override
  List<Object> get props => [message];
}