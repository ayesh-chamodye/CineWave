import 'package:equatable/equatable.dart';
import 'package:cinewave/core/models/library_models.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibrary extends LibraryEvent {}

class AddToHistory extends LibraryEvent {
  final WatchHistoryItem item;
  const AddToHistory(this.item);

  @override
  List<Object?> get props => [item];
}

class ToggleFavorite extends LibraryEvent {
  final FavoriteItem item;
  const ToggleFavorite(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteHistoryItem extends LibraryEvent {
  final String id;
  const DeleteHistoryItem(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearHistory extends LibraryEvent {}
