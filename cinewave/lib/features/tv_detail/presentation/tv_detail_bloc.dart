import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cinewave/features/tv_detail/data/repositories/tv_detail_repository.dart';
import 'package:cinewave/core/models/media_models.dart';

part 'tv_detail_event.dart';
part 'tv_detail_state.dart';

class TVDetailBloc extends Bloc<TVDetailEvent, TVDetailState> {
  final TVDetailRepository tvDetailRepository;

  TVDetailBloc({required this.tvDetailRepository})
      : super(TVDetailInitial()) {
    on<LoadTVDetail>(_onLoadTVDetail);
  }

  Future<void> _onLoadTVDetail(
      LoadTVDetail event, Emitter<TVDetailState> emit) async {
    emit(TVDetailLoading());
    try {
      final TVShow tvShowDetail = await tvDetailRepository
          .getTvDetail(event.tvShow.id, tmdbUrl: event.tvShow.tmdbUrl);
      emit(TVDetailLoaded(tvShow: tvShowDetail));
    } catch (e) {
      emit(TVDetailError(message: e.toString()));
    }
  }
}