class ApiEndpoints {
  static const String baseUrl = 'https://movie-scrape-silk.vercel.app';

  // Home
  static const String home = '/api/home';

  // Movies
  static const String moviesLatest = '/api/movies/latest';
  static String moviesSearch(String query) => '/api/movies/search?q=$query';
  static String movieDetail(int movieId) => '/api/movies/$movieId';

  // TV Shows
  static const String tvLatest = '/api/tv/latest';
  static String tvSearch(String query) => '/api/tv/search?q=$query';
  static String tvDetail(int tvId) => '/api/tv/$tvId';
}