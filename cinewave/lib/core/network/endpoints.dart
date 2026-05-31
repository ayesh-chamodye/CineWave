class ApiEndpoints {
  /// New backend base URL — GitHub Codespace port-forward
  /// (gateway page visible externally, app must be in same network)
  static const String baseUrl = 'https://movie-scrape-silk.vercel.app';

  // ── Home ──────────────────────────────────────────────────────────────
  // Returns { movies?: [...], tvShows?: [...], trendingMovies?: [...] }
  // Also supports legacy { popular: [...media items with "mediaType" key] }
  static const String home = '/api/home';

  // ── Movies ────────────────────────────────────────────────────────────
  static const String moviesLatest = '/api/movies/latest';
  static String moviesSearch(String query) => '/api/movies/search?q=$query';

  // ── TV Shows ───────────────────────────────────────────────────────────
  static const String tvLatest = '/api/tv/latest';
  static String tvSearch(String query) => '/api/tv/search?q=$query';
  /// Returns `{ movies: [...], page: N, totalPages: N }` — 20 items per page.
  static String moviesAll(int page) => '/api/movies/all?page=$page';

  /// Returns `{ tvShows: [...], page: N, totalPages: N }` — 20 items per page.
  static String tvAll(int page) => '/api/tv/all?page=$page';



  // ── Scrape endpoints (new) ─────────────────────────────────────────────
  /// Scrapes a TMDB movie page and returns enriched JSON with a direct video URL.
  static String scrapeMovie(String tmdbUrl) =>
      '/api/scrape?url=${Uri.encodeComponent(tmdbUrl)}';

  /// Scrapes a TMDB TV-show page and returns enriched JSON with a direct video URL.
  static String scrapeTV(String tmdbUrl) =>
      '/api/scrape?url=${Uri.encodeComponent(tmdbUrl)}';

  // ── Image CDN ──────────────────────────────────────────────────────────
  static String tmdbPoster(String posterPath) =>
      'https://www.themoviedb.org/t/p/w342$posterPath';
  static String tmdbBackdrop(String backdropPath) =>
      'https://www.themoviedb.org/t/p/w780$backdropPath';
}