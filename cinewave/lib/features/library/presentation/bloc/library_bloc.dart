import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinewave/features/library/data/repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<AddToHistory>(_onAddToHistory);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ToggleWatchlist>(_onToggleWatchlist);
    on<DeleteHistoryItem>(_onDeleteHistoryItem);
    on<ClearHistory>(_onClearHistory);
  }

  Future<void> _onLoadLibrary(LoadLibrary event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final history = await repository.getWatchHistory();
      final favorites = await repository.getFavorites();
      final watchlist = await repository.getWatchlist();
      emit(LibraryLoaded(history: history, favorites: favorites, watchlist: watchlist));
    } catch (e) {
      emit(LibraryError(e.toString()));
    }
  }

  Future<void> _onAddToHistory(AddToHistory event, Emitter<LibraryState> emit) async {
    try {
      await repository.saveWatchHistory(event.item);
      add(LoadLibrary());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<LibraryState> emit) async {
    try {
      await repository.toggleFavorite(event.item);
      add(LoadLibrary());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onToggleWatchlist(ToggleWatchlist event, Emitter<LibraryState> emit) async {
    try {
      await repository.toggleWatchlist(event.item);
      add(LoadLibrary());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onDeleteHistoryItem(DeleteHistoryItem event, Emitter<LibraryState> emit) async {
    try {
      await repository.deleteWatchHistoryItem(event.id);
      add(LoadLibrary());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onClearHistory(ClearHistory event, Emitter<LibraryState> emit) async {
    try {
      await repository.clearWatchHistory();
      add(LoadLibrary());
    } catch (e) {
      // Handle error
    }
  }
}
