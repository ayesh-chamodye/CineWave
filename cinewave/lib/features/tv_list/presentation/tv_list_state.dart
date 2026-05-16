part of 'tv_list_bloc.dart';

abstract class TVListState extends Equatable {
  const TVListState();

  @override
  List<Object?> get props => [];
}

class TVListInitial extends TVListState {
  const TVListInitial();
}

class TVListLoading extends TVListState {
  const TVListLoading();
}

class TVListLoaded extends TVListState {
  final List<TVShow> tvShows;
  final int page;
  final int totalPages;
  final bool hasReachedMax;

  const TVListLoaded({
    required this.tvShows,
    required this.page,
    required this.totalPages,
    this.hasReachedMax = false,
  });

  TVListLoaded copyWith({
    List<TVShow>? tvShows,
    int? page,
    int? totalPages,
    bool? hasReachedMax,
  }) {
    return TVListLoaded(
      tvShows: tvShows ?? this.tvShows,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [tvShows, page, totalPages, hasReachedMax];
}

class TVListSearchLoaded extends TVListState {
  final List<TVShow> tvShows;

  const TVListSearchLoaded({
    required this.tvShows,
  });

  @override
  List<Object?> get props => [tvShows];
}

class TVListError extends TVListState {
  final String message;

  const TVListError({required this.message});

  @override
  List<Object> get props => [message];
}
