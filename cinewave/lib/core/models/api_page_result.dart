/// Lightweight carrier for a paginated API response.
class ApiPageResult<T> {
  final List<T> items;
  final int page;
  final int totalPages;

  ApiPageResult({
    required this.items,
    required this.page,
    required this.totalPages,
  });
}
