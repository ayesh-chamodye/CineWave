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
      'tmdbUrl': tmdbUrl,
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
  final String? lastAirDate;
  final double voteAverage;
  final String? videoUrl;
  final String playerUrl;
  final String? tmdbUrl;
  final int? seasonNumber;
  final int? episodeNumber;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<SeasonInfo> seasons;

  TVShow({
    required this.id,
    required this.name,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.firstAirDate,
    this.lastAirDate,
    required this.voteAverage,
    this.videoUrl,
    this.playerUrl = '',
    this.tmdbUrl,
    this.seasonNumber,
    this.episodeNumber,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.seasons = const [],
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Unknown',
      posterUrl: json['posterUrl'] ?? json['poster_path'] ?? '',
      backdropUrl: json['backdropUrl'] ?? json['backdrop_path'] ?? '',
      overview: json['overview'] ?? '',
      firstAirDate: json['firstAirDate'] ?? json['first_air_date'] ?? '',
      lastAirDate: json['lastAirDate'] ?? json['last_air_date'],
      voteAverage: (json['voteAverage'] ?? json['vote_average'] ?? 0.0).toDouble(),
      videoUrl: json['videoUrl'] ?? json['video_url'] ?? json['trailer'] ?? '',
      playerUrl: json['playerUrl'] ?? '',
      tmdbUrl: json['tmdbUrl'] ?? json['tmdb_url'],
      seasonNumber: json['seasonNumber'] ?? json['season_number'],
      episodeNumber: json['episodeNumber'] ?? json['episode_number'],
      numberOfSeasons: json['numberOfSeasons'] ?? json['number_of_seasons'],
      numberOfEpisodes: json['numberOfEpisodes'] ?? json['number_of_episodes'],
      seasons: _parseSeasons(json['seasons']),
    );
  }

  static List<SeasonInfo> _parseSeasons(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => SeasonInfo.fromJson(json))
        .where((s) => s.seasonNumber != 0)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'overview': overview,
      'firstAirDate': firstAirDate,
      'lastAirDate': lastAirDate,
      'voteAverage': voteAverage,
      'videoUrl': videoUrl,
      'playerUrl': playerUrl,
      'tmdbUrl': tmdbUrl,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'numberOfSeasons': numberOfSeasons,
      'numberOfEpisodes': numberOfEpisodes,
      'seasons': seasons.map((s) => s.toJson()).toList(),
    };
  }
}

class SeasonInfo {
  final int id;
  final int seasonNumber;
  final String name;
  final String? posterPath;
  final int episodeCount;

  const SeasonInfo({
    required this.id,
    required this.seasonNumber,
    required this.name,
    this.posterPath,
    required this.episodeCount,
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      id: json['id'] ?? 0,
      seasonNumber: json['season_number'] ?? 1,
      name: json['name'] ?? 'Season ${json['season_number'] ?? 1}',
      posterPath: json['poster_path'],
      episodeCount: json['episode_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'season_number': seasonNumber,
      'name': name,
      'poster_path': posterPath,
      'episode_count': episodeCount,
    };
  }
}

