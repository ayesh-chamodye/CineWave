class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final String releaseDate;
  final double voteAverage;
  final String? videoUrl;
  final String playerUrl;
  final String? tmdbUrl;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
    this.videoUrl,
    this.playerUrl = '',
    this.tmdbUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      posterUrl: json['posterUrl'] ?? json['poster_path'] ?? '',
      backdropUrl: json['backdropUrl'] ?? json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['releaseDate'] ?? json['release_date'] ?? '',
      voteAverage: (json['voteAverage'] ?? json['vote_average'] ?? 0.0).toDouble(),
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? json['trailer'] ?? '',
      playerUrl: json['playerUrl'] ?? '',
      tmdbUrl: json['tmdbUrl'] ?? json['tmdb_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'videoUrl': videoUrl,
      'playerUrl': playerUrl,
    };
  }
}

class TVShow {
  final int id;
  final String name;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final String firstAirDate;
  final double voteAverage;
  final String? videoUrl;
  final String playerUrl;
  final String? tmdbUrl;
  final int? seasonNumber;
  final int? episodeNumber;

  TVShow({
    required this.id,
    required this.name,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.firstAirDate,
    required this.voteAverage,
    this.videoUrl,
    this.playerUrl = '',
    this.tmdbUrl,
    this.seasonNumber,
    this.episodeNumber,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Unknown',
      posterUrl: json['posterUrl'] ?? json['poster_path'] ?? '',
      backdropUrl: json['backdropUrl'] ?? json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      firstAirDate: json['firstAirDate'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['voteAverage'] ?? json['vote_average'] ?? 0.0).toDouble(),
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? json['trailer'] ?? '',
      playerUrl: json['playerUrl'] ?? '',
      tmdbUrl: json['tmdbUrl'] ?? json['tmdb_url'],
      seasonNumber: json['seasonNumber'] ?? json['season_number'],
      episodeNumber: json['episodeNumber'] ?? json['episode_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'firstAirDate': firstAirDate,
      'voteAverage': voteAverage,
      'videoUrl': videoUrl,
      'playerUrl': playerUrl,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
    };
  }
}
