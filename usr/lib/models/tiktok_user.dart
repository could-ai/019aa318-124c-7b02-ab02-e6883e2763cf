class TikTokUser {
  final String id;
  final String username;
  final String displayName;
  final String profileImageUrl;
  final bool followsYou;
  bool isFollowing;

  TikTokUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.profileImageUrl,
    required this.followsYou,
    this.isFollowing = true,
  });
}
