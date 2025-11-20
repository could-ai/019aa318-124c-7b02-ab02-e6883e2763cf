import 'dart:math';
import '../models/tiktok_user.dart';

class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<TikTokUser> _following = [];
  
  // Generate mock data
  Future<void> fetchUserData() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    
    _following = List.generate(50, (index) {
      // Randomly decide if they follow back (approx 40% don't follow back)
      bool followsBack = Random().nextBool() && Random().nextBool(); 
      
      return TikTokUser(
        id: 'user_$index',
        username: 'user_tiktok_$index',
        displayName: 'TikTok User $index',
        profileImageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=$index',
        followsYou: followsBack,
        isFollowing: true,
      );
    });
  }

  List<TikTokUser> getFollowing() {
    return _following.where((u) => u.isFollowing).toList();
  }

  List<TikTokUser> getNonFollowers() {
    return _following.where((u) => u.isFollowing && !u.followsYou).toList();
  }

  List<TikTokUser> getFans() {
    // For this demo, we'll just assume fans are people who follow you but you might not follow back
    // But strictly based on our model, we only track people WE follow currently.
    // Let's just return people who follow us back from our following list for stats.
    return _following.where((u) => u.followsYou).toList();
  }

  Future<void> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    final index = _following.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _following[index].isFollowing = false;
    }
  }

  Future<void> unfollowMultiple(List<String> userIds) async {
    for (var id in userIds) {
      await unfollowUser(id);
    }
  }
}
