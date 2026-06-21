import 'package:equatable/equatable.dart';
import 'package:cinewave/core/models/library_models.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<WatchHistoryItem> history;
  final List<FavoriteItem> favorites;

  const LibraryLoaded({
    required this.history,
    required this.favorites,
  });

  @override
  List<Object?> get props => [history, favorites];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
