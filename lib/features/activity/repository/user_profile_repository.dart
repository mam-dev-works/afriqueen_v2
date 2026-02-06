import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_profile_model.dart';
import '../model/story_model.dart';
import '../../../services/invisible_mode_service.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final InvisibleModeService _invisibleModeService = InvisibleModeService();

  // Get all users for activity page
  Stream<List<UserProfileModel>> getAllUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream');
      return Stream.value([]);
    }

    print('UserProfileRepository: Fetching users for current user: $currentUserId');

    return _firestore
        .collection('user')
        .where('id', isNotEqualTo: currentUserId) // Exclude current user
        .snapshots()
        .map((snapshot) {
      print('UserProfileRepository: Query returned ${snapshot.docs.length} documents');
      
      final users = snapshot.docs.map((doc) {
        print('UserProfileRepository: Processing document: ${doc.id}');
        final data = doc.data();
        print('UserProfileRepository: Document data keys: ${data.keys.toList()}');
        
        // Debug: Check specific fields
        print('UserProfileRepository: Has photos field: ${data.containsKey('photos')}');
        if (data.containsKey('photos')) {
          print('UserProfileRepository: Photos field: ${data['photos']}');
          print('UserProfileRepository: Photos field type: ${data['photos'].runtimeType}');
          if (data['photos'] is List) {
            print('UserProfileRepository: Photos list length: ${(data['photos'] as List).length}');
          }
        }
        print('UserProfileRepository: Has name field: ${data.containsKey('name')}');
        if (data.containsKey('name')) {
          print('UserProfileRepository: Name field: ${data['name']}');
        }
        
        return UserProfileModel.fromFirestore(doc);
      }).toList();
      
      print('UserProfileRepository: Fetched ${users.length} users from Firestore');
      
      // Debug: Print first few users
      if (users.isNotEmpty) {
        final firstUser = users.first;
        print('UserProfileRepository: First user - ID: ${firstUser.id}, Name: ${firstUser.name}, Pseudo: ${firstUser.pseudo}');
        print('UserProfileRepository: First user photos: ${firstUser.photos}');
      }
      
      return users;
    });
  }

  // Get viewed users (users who viewed current user)
  Stream<List<UserProfileModel>> getViewedUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream for viewed users');
      return Stream.value([]);
    }

    return _firestore
        .collection('profile_views')
        .where('viewedId', isEqualTo: currentUserId)
        .orderBy('lastViewedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<UserProfileModel> users = [];
      final Map<String, UserProfileModel> cache = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final viewerId = data['viewerId'] as String?;
        if (viewerId == null || viewerId.isEmpty) {
          continue;
        }

        if (cache.containsKey(viewerId)) {
          users.add(cache[viewerId]!);
          continue;
        }

        final user = await _fetchUserById(viewerId);
        if (user != null) {
          // Check if user is invisible and we haven't interacted
          final isInvisible = await _invisibleModeService.isUserInvisible(user.id);
          if (!isInvisible) {
            cache[viewerId] = user;
            users.add(user);
          } else {
            final hasInteracted = await _invisibleModeService.hasInteractedWith(user.id);
            if (hasInteracted) {
              cache[viewerId] = user;
              users.add(user);
            }
          }
        }
      }

      return users;
    }).handleError((error, stackTrace) {
      print('UserProfileRepository: Error fetching viewed users stream: $error');
      return <UserProfileModel>[];
    });
  }

  // Get users that current user viewed
  Stream<List<UserProfileModel>> getUsersIViewedStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream for users I viewed');
      return Stream.value([]);
    }

    return _firestore
        .collection('profile_views')
        .where('viewerId', isEqualTo: currentUserId)
        .orderBy('lastViewedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<UserProfileModel> users = [];
      final Map<String, UserProfileModel> cache = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final viewedId = data['viewedId'] as String?;
        if (viewedId == null || viewedId.isEmpty) {
          continue;
        }

        if (cache.containsKey(viewedId)) {
          users.add(cache[viewedId]!);
          continue;
        }

        final user = await _fetchUserById(viewedId);
        if (user != null) {
          // Check if user is invisible and we haven't interacted
          final isInvisible = await _invisibleModeService.isUserInvisible(user.id);
          if (!isInvisible) {
            cache[viewedId] = user;
            users.add(user);
          } else {
            final hasInteracted = await _invisibleModeService.hasInteractedWith(user.id);
            if (hasInteracted) {
              cache[viewedId] = user;
              users.add(user);
            }
          }
        }
      }

      return users;
    }).handleError((error, stackTrace) {
      print('UserProfileRepository: Error fetching users I viewed stream: $error');
      return <UserProfileModel>[];
    });
  }

  // Mark user as viewed
  Future<void> markUserAsViewed(String userId) async {
    final viewerId = _auth.currentUser?.uid;
    if (viewerId == null) {
      print('UserProfileRepository: Cannot mark viewed - no current user');
      return;
    }

    if (viewerId == userId) {
      print('UserProfileRepository: Skipping mark viewed for self');
      return;
    }

    final docId = '${viewerId}_$userId';
    final docRef = _firestore.collection('profile_views').doc(docId);
    final now = FieldValue.serverTimestamp();

    print('UserProfileRepository: Attempting to mark user as viewed');
    print('UserProfileRepository: viewerId=$viewerId, viewedId=$userId, docId=$docId');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          print('UserProfileRepository: Document exists, updating view count');
          final currentCount = (snapshot.data()?['viewCount'] as int?) ?? 0;
          transaction.update(docRef, {
            'lastViewedAt': now,
            'viewCount': currentCount + 1,
          });
        } else {
          print('UserProfileRepository: Document does not exist, creating new');
          transaction.set(docRef, {
            'viewerId': viewerId,
            'viewedId': userId,
            'firstViewedAt': now,
            'lastViewedAt': now,
            'viewCount': 1,
          });
        }
      });
      print('UserProfileRepository: Successfully marked user $userId as viewed');
    } catch (e, stackTrace) {
      print('UserProfileRepository: Error marking user $userId as viewed: $e');
      print('UserProfileRepository: Stack trace: $stackTrace');
      // Don't rethrow to prevent app crashes, but log the error
    }
  }

  // Remove user from viewed list
  Future<void> removeUserFromViewed(String userId) async {
    final viewerId = _auth.currentUser?.uid;
    if (viewerId == null) {
      print('UserProfileRepository: Cannot remove viewed user - no current user');
      return;
    }

    final docId = '${viewerId}_$userId';
    final docRef = _firestore.collection('profile_views').doc(docId);

    try {
      await docRef.delete();
    } catch (e) {
      print('UserProfileRepository: Error removing viewed user $userId: $e');
    }
  }

  Future<UserProfileModel?> _fetchUserById(String userId) async {
    try {
      final query = await _firestore
          .collection('user')
          .where('id', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('UserProfileRepository: No user found for id $userId');
        return null;
      }

      return UserProfileModel.fromFirestore(query.docs.first);
    } catch (e) {
      print('UserProfileRepository: Error fetching user $userId: $e');
      return null;
    }
  }

  // Get users who liked current user
  Stream<List<UserProfileModel>> getLikedUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream');
      return Stream.value([]);
    }

    print('UserProfileRepository: Fetching users who liked current user: $currentUserId');

    return _firestore
        .collection('likes')
        .where('likedUserId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      print('UserProfileRepository: Likes query returned ${snapshot.docs.length} documents');
      
      final List<UserProfileModel> likedUsers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final likerId = data['likerId'] as String?;
        
        if (likerId != null) {
          try {
            // Fetch user details for each liker
            final userDoc = await _firestore
                .collection('user')
                .where('id', isEqualTo: likerId)
                .get();
            
            if (userDoc.docs.isNotEmpty) {
              final user = UserProfileModel.fromFirestore(userDoc.docs.first);
              // Check if user is invisible and we haven't interacted
              final isInvisible = await _invisibleModeService.isUserInvisible(user.id);
              if (!isInvisible) {
                likedUsers.add(user);
                print('UserProfileRepository: Added liked user - ID: ${user.id}, Name: ${user.name}');
              } else {
                final hasInteracted = await _invisibleModeService.hasInteractedWith(user.id);
                if (hasInteracted) {
                  likedUsers.add(user);
                  print('UserProfileRepository: Added liked user (interacted) - ID: ${user.id}, Name: ${user.name}');
                }
              }
            }
          } catch (e) {
            print('UserProfileRepository: Error fetching user $likerId: $e');
          }
        }
      }
      
      print('UserProfileRepository: Fetched ${likedUsers.length} users who liked current user');
      return likedUsers;
    });
  }

  // Get users that current user liked
  Stream<List<UserProfileModel>> getUsersILikedStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream');
      return Stream.value([]);
    }

    print('UserProfileRepository: Fetching users that current user liked: $currentUserId');

    return _firestore
        .collection('likes')
        .where('likerId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      print('UserProfileRepository: Likes query returned ${snapshot.docs.length} documents');
      
      final List<UserProfileModel> likedUsers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final likedUserId = data['likedUserId'] as String?;
        
        if (likedUserId != null) {
          try {
            // Fetch user details for each liked user
            final userDoc = await _firestore
                .collection('user')
                .where('id', isEqualTo: likedUserId)
                .get();
            
            if (userDoc.docs.isNotEmpty) {
              final user = UserProfileModel.fromFirestore(userDoc.docs.first);
              // Check if user is invisible and we haven't interacted
              final isInvisible = await _invisibleModeService.isUserInvisible(user.id);
              if (!isInvisible) {
                likedUsers.add(user);
                print('UserProfileRepository: Added user I liked - ID: ${user.id}, Name: ${user.name}');
              } else {
                final hasInteracted = await _invisibleModeService.hasInteractedWith(user.id);
                if (hasInteracted) {
                  likedUsers.add(user);
                  print('UserProfileRepository: Added user I liked (interacted) - ID: ${user.id}, Name: ${user.name}');
                }
              }
            }
          } catch (e) {
            print('UserProfileRepository: Error fetching user $likedUserId: $e');
          }
        }
      }
      
      print('UserProfileRepository: Fetched ${likedUsers.length} users that current user liked');
      return likedUsers;
    });
  }

  // Get users who liked current user's stories
  Stream<List<UserProfileModel>> getStoryLikedUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream');
      return Stream.value([]);
    }

    print('UserProfileRepository: Fetching users who liked current user stories: $currentUserId');

    return _firestore
        .collection('stories_likes')
        .where('likedUserId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      print('UserProfileRepository: Story likes query returned ${snapshot.docs.length} documents');
      
      final List<UserProfileModel> likedUsers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final likerId = data['likedUserId'] as String?;
        
        if (likerId != null) {
          try {
            // Fetch user details for each liker
            final userDoc = await _firestore
                .collection('user')
                .where('id', isEqualTo: likerId)
                .get();
            
            if (userDoc.docs.isNotEmpty) {
              final user = UserProfileModel.fromFirestore(userDoc.docs.first);
              likedUsers.add(user);
              print('UserProfileRepository: Added story liked user - ID: ${user.id}, Name: ${user.name}');
            }
          } catch (e) {
            print('UserProfileRepository: Error fetching user $likerId: $e');
          }
        }
      }
      
      print('UserProfileRepository: Fetched ${likedUsers.length} users who liked current user stories');
      return likedUsers;
    });
  }

  // Get users that current user liked their stories
  Stream<List<UserProfileModel>> getUsersILikedStoryStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream');
      return Stream.value([]);
    }

    print('UserProfileRepository: Fetching users whose stories current user liked: $currentUserId');

    return _firestore
        .collection('stories_likes')
        .where('likedUserId', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      print('UserProfileRepository: Story likes query returned ${snapshot.docs.length} documents');
      
      final List<UserProfileModel> likedUsers = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final likedStoryId = data['likedStoryId'] as String?;
        
        if (likedStoryId != null) {
          try {
            // First get the story to find the story owner
            final storyDoc = await _firestore
                .collection('stories')
                .doc(likedStoryId)
                .get();
            
            if (storyDoc.exists) {
              final storyData = storyDoc.data()!;
              final storyOwnerId = storyData['userId'] as String?;
              
              if (storyOwnerId != null) {
                // Fetch user details for story owner
                final userDoc = await _firestore
                    .collection('user')
                    .where('id', isEqualTo: storyOwnerId)
                    .get();
                
                if (userDoc.docs.isNotEmpty) {
                  final user = UserProfileModel.fromFirestore(userDoc.docs.first);
                  likedUsers.add(user);
                  print('UserProfileRepository: Added user whose story I liked - ID: ${user.id}, Name: ${user.name}');
                }
              }
            }
          } catch (e) {
            print('UserProfileRepository: Error fetching user for story $likedStoryId: $e');
          }
        }
      }
      
      print('UserProfileRepository: Fetched ${likedUsers.length} users whose stories current user liked');
      return likedUsers;
    });
  }

  // ========================= STORIES =========================
  // Get all stories (Viewed)
  Stream<List<StoryModel>> getAllStoriesStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('stories')
        .orderBy('createdDate', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<StoryModel> visibleStories = [];
      
      for (final doc in snapshot.docs) {
        final story = StoryModel.fromFirestore(doc);
        final storyOwnerId = story.uid;
        
        // Skip current user's own stories
        if (storyOwnerId == currentUserId) {
          visibleStories.add(story);
          continue;
        }
        
        // Check if story owner is invisible and we haven't interacted
        final isInvisible = await _invisibleModeService.isUserInvisible(storyOwnerId);
        if (!isInvisible) {
          visibleStories.add(story);
        } else {
          final hasInteracted = await _invisibleModeService.hasInteractedWith(storyOwnerId);
          if (hasInteracted) {
            visibleStories.add(story);
          }
        }
      }
      
      return visibleStories;
    });
  }

  // Get stories I liked (through stories_likes)
  Stream<List<StoryModel>> getStoriesILikedStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream for liked stories');
      return Stream.value([]);
    }

    return _firestore
        .collection('stories_likes')
        .where('likedUserId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<StoryModel> stories = [];
      for (final likeDoc in snapshot.docs) {
        final data = likeDoc.data();
        final likedStoryId = data['likedStoryId'] as String?;
        if (likedStoryId == null) continue;
        try {
          final storyDoc = await _firestore.collection('stories').doc(likedStoryId).get();
          if (storyDoc.exists) {
            stories.add(StoryModel.fromFirestore(storyDoc));
          }
        } catch (e) {
          print('UserProfileRepository: error fetching story $likedStoryId: $e');
        }
      }
      return stories;
    });
  }

  // Get my stories
  Stream<List<StoryModel>> getMyStoriesStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      print('UserProfileRepository: No current user, returning empty stream for my stories');
      return Stream.value([]);
    }
    return _firestore
        .collection('stories')
        .where('uid', isEqualTo: currentUserId)
        .orderBy('createdDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => StoryModel.fromFirestore(d)).toList());
  }
}
