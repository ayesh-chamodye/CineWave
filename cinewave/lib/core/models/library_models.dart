class WatchHistoryItem {
  final String id;
  final String mediaId;
  final String title;
  final String? posterUrl;
  final String type;
  final int? season;
  final int? episode;
  final int position;
  final int duration;
  final DateTime lastWatched;

  WatchHistoryItem({
    required this.id,
    required this.mediaId,
    required this.title,
    this.posterUrl,
    required this.type,
    this.season,
    this.episode,
    required this.position,
    required this.duration,
    required this.lastWatched,
  });

  double get progress => duration > 0 ? position / duration : 0;
  bool get isCompleted => progress > 0.9;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mediaId': mediaId,
      'title': title,
      'posterUrl': posterUrl,
      'type': type,
      'season': season,
      'episode': episode,
      'position': position,
      'duration': duration,
      'lastWatched': lastWatched.toIso8601String(),
    };
  }

  factory WatchHistoryItem.fromMap(Map<String, dynamic> map) {
    return WatchHistoryItem(
      id: map['id'],
      mediaId: map['mediaId'],
      title: map['title'],
      posterUrl: map['posterUrl'],
      type: map['type'],
      season: map['season'],
      episode: map['episode'],
      position: map['position'],
      duration: map['duration'],
      lastWatched: DateTime.parse(map['lastWatched']),
    );
  }
}

class FavoriteItem {
  final String mediaId;
  final String title;
  final String? posterUrl;
  final String? backdropUrl;
  final String? overview;
  final String type;
  final double rating;
  final String? releaseDate;

  FavoriteItem({
    required this.mediaId,
    required this.title,
    this.posterUrl,
    this.backdropUrl,
    this.overview,
    required this.type,
    this.rating = 0.0,
    this.releaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'mediaId': mediaId,
      'title': title,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'type': type,
      'rating': rating,
      'releaseDate': releaseDate,
    };
  }

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      mediaId: map['mediaId'],
      title: map['title'],
      posterUrl: map['posterUrl'],
      backdropUrl: map['backdropUrl'],
      overview: map['overview'],
      type: map['type'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      releaseDate: map['releaseDate'],
    );
  }
}
