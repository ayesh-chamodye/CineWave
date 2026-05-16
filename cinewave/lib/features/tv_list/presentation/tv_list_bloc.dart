import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/tv_list/data/repositories/tv_list_repository.dart';
import 'package:cinewave/core/models/media_models.dart';
import 'package:cinewave/core/models/api_page_result.dart';

part 'tv_list_event.dart';
part 'tv_list_state.dart';

class TVListBloc extends Bloc<TVListEvent, TVListState> {
  static const int _firstPage = 1;

  final TVListRepository _repository;
  final List<TVShow> _allShows = [];

  TVListBloc({required TVListRepository repository})
      : _repository = repository,
        super(const TVListInitial()) {
    on<LoadTVPage>(_onLoadTVPage);
    on<SearchTV>(_onSearchTV);
  }

  Future<void> _onLoadTVPage(
    LoadTVPage event,
    Emitter<TVListState> emit,
  ) async {
    if (event.page > _firstPage &&
        state is TVListLoaded &&
        (state as TVListLoaded).hasReachedMax) {
      return;
    }

    if (event.page == _firstPage) {
      emit(const TVListLoading());
    }

    try {
      final ApiPageResult<TVShow> result =
          await _repository.getTVPage(event.page);

      _allShows.addAll(result.items);

      final hasReachedMax = result.page >= result.totalPages;

      emit(TVListLoaded(
        tvShows: List<TVShow>.from(_allShows),
        page: result.page,
        totalPages: result.totalPages,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(TVListError(message: e.toString()));
    }
  }

  Future<void> _onSearchTV(
    SearchTV event,
    Emitter<TVListState> emit,
  ) async {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(const TVListLoading());
      return;
    }

    try {
      final ApiPageResult<TVShow> result =
          await _repository.searchTvShows(trimmed);

      emit(TVListSearchLoaded(tvShows: result.items));
    } catch (e) {
      emit(TVListError(message: e.toString()));
    }
  }
}
