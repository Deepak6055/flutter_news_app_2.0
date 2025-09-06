import 'dart:collection';

class LocalNewsInteractionService {
  // Singleton pattern
  static final LocalNewsInteractionService _instance = LocalNewsInteractionService._internal();
  factory LocalNewsInteractionService() => _instance;
  LocalNewsInteractionService._internal();

  // Store likes and comments by news link
  final Map<String, bool> _likes = {};
  final Map<String, List<String>> _comments = {};

  // Like or unlike a news item
  void toggleLike(String link) {
    _likes[link] = !(_likes[link] ?? false);
  }

  bool isLiked(String link) {
    return _likes[link] ?? false;
  }

  // Add a comment to a news item
  void addComment(String link, String comment) {
    _comments.putIfAbsent(link, () => []);
    _comments[link]!.add(comment);
  }

  List<String> getComments(String link) {
    return List.unmodifiable(_comments[link] ?? []);
  }

  // For viewing all liked links (optional)
  List<String> getLikedLinks() {
    return _likes.entries.where((e) => e.value).map((e) => e.key).toList();
  }
}
