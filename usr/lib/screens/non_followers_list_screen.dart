import 'package:flutter/material.dart';
import '../models/tiktok_user.dart';
import '../services/data_service.dart';

class NonFollowersListScreen extends StatefulWidget {
  const NonFollowersListScreen({super.key});

  @override
  State<NonFollowersListScreen> createState() => _NonFollowersListScreenState();
}

class _NonFollowersListScreenState extends State<NonFollowersListScreen> {
  final DataService _dataService = DataService();
  List<TikTokUser> _nonFollowers = [];
  bool _isLoading = false;
  Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  void _loadList() {
    if (!mounted) return;
    setState(() {
      _nonFollowers = _dataService.getNonFollowers();
    });
  }

  Future<void> _unfollowUser(TikTokUser user) async {
    if (!mounted) return;
    setState(() {
      _processingIds.add(user.id);
    });

    await _dataService.unfollowUser(user.id);

    if (mounted) {
      setState(() {
        _processingIds.remove(user.id);
        _loadList(); // Refresh list to remove the user
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unfollowed ${user.username}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _unfollowTop10() async {
    if (_nonFollowers.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Take up to 10 users
    final usersToUnfollow = _nonFollowers.take(10).map((u) => u.id).toList();
    
    // Simulate processing one by one for visual effect
    for (var id in usersToUnfollow) {
      if (!mounted) return; // Stop if user left the screen
      
      await _dataService.unfollowUser(id);
      
      if (mounted) {
        setState(() {
          _loadList();
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch unfollow complete')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Non-Followers'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_nonFollowers.length} Users',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Don\'t follow you back',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: (_isLoading || _nonFollowers.isEmpty) ? null : _unfollowTop10,
                  icon: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.bolt),
                  label: const Text('Unfollow Top 10'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _nonFollowers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'You\'re all good!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Everyone you follow follows you back.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _nonFollowers.length,
                    itemBuilder: (context, index) {
                      final user = _nonFollowers[index];
                      final isProcessing = _processingIds.contains(user.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          backgroundImage: NetworkImage(user.profileImageUrl),
                          onBackgroundImageError: (_, __) {},
                          child: const Icon(Icons.person),
                        ),
                        title: Text(
                          user.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('@${user.username}'),
                        trailing: SizedBox(
                          width: 100,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: (_isLoading || isProcessing) ? null : () => _unfollowUser(user),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[700]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: isProcessing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(
                                    'Unfollow',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
