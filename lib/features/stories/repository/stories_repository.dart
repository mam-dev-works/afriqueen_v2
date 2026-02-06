import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class StoriesRepository {
  final FirebaseFirestore firestore;
  final cloudinary = CloudinaryPublic(
    AppStrings.cloudName,
    AppStrings.uploadPreset,
  );

  final ImagePicker _imagePicker = ImagePicker();
  StoriesRepository({FirebaseFirestore? fire})
      : firestore = fire ?? FirebaseFirestore.instance;
  //--------------------------------Image adding to cloudinary-----------------------------
  Future<String?> addStoriesImageToCloudinary(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: "afriqueen/stories",
          publicId: "${DateTime.now().millisecondsSinceEpoch}",
        ),
      );
      return response.secureUrl;
    } catch (e) {
      rethrow;
    }
  }

  //--------------------------------Create story with image and text-----------------------------
  Future<void> createStory(File imageFile, String text) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await addStoriesImageToCloudinary(imageFile);
      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile data
      final userQuery = await firestore
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User profile not found');
      }

      final userData = userQuery.docs.first.data();
      final userName = userData['name'] ?? 'Unknown User';
      final userImg = userData['image'] ?? '';

      // Create story data
      final storyData = {
        'imageUrl': imageUrl,
        'text': text,
        'uid': currentUser.uid,
        'userName': userName,
        'userImg': userImg,
        'createdDate': FieldValue.serverTimestamp(),
      };

      // Add to stories collection
      await firestore.collection('stories').add(storyData);
    } catch (e) {
      rethrow;
    }
  }

  //  User Stories data uploading  to  firebase
  Future<void> uploadStoriesToFirebase(StoriesModel model) async {
    final storyCollection = firestore.collection('stories');

    // Check if a story already exists for this user (assuming 'id' is unique per user)
    final querySnapshot =
        await storyCollection.where('id', isEqualTo: model.uid).get();

    if (querySnapshot.docs.isEmpty) {
      // No story exists, create a new one
      final Map<String, dynamic> data = {
        'id': model.uid,
        'containUrl': model.containUrl,
        'createdDate': model.createdDate,
        'userName': model.userName,
        'userImg': model.userImg,
      };

      await storyCollection.add(data); // .add() generates a new document
    } else {
      // Story exists, update the containUrl field
      final docId = querySnapshot.docs.first.id;

      await storyCollection.doc(docId).update({
        'containUrl': FieldValue.arrayUnion(model.containUrl),
        'createdDate': FieldValue.arrayUnion(model.createdDate),
      });
    }
  }

  Future<List<StoriesFetchModel>> fetchAllStoriesData() async {
    try {
      final snapshot = await firestore.collection('stories').get();
      print("Fetched documents: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        print("Parsing document: ${doc.data()}");
        final data = doc.data();
        data['documentId'] = doc.id; // Add document ID to the data
        print("Document ID: ${doc.id}");
        final story = StoriesFetchModel.fromMap(data);
        print("Created story with documentId: ${story.documentId}");
        return story;
      }).toList();

      
    } catch (e) {
      print("Error fetching stories: $e");
      rethrow;
    }
  }

  //--------------------------------Story Like Functions-----------------------------
  Future<void> likeStory(String storyId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      await firestore.collection('stories_likes').add({
        'likedUserId': currentUserId,
        'likedStoryId': storyId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error liking story: $e');
      rethrow;
    }
  }

  Future<void> unlikeStory(String storyId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final likeQuery = await firestore
          .collection('stories_likes')
          .where('likedUserId', isEqualTo: currentUserId)
          .where('likedStoryId', isEqualTo: storyId)
          .get();

      for (var doc in likeQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error unliking story: $e');
      rethrow;
    }
  }

  Future<bool> hasLikedStory(String storyId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return false;

      print('=== LIKE STATUS CHECK ===');
      print('Checking if story $storyId is liked by user $currentUserId');

      final likeQuery = await firestore
          .collection('stories_likes')
          .where('likedUserId', isEqualTo: currentUserId)
          .where('likedStoryId', isEqualTo: storyId)
          .get();

      final isLiked = likeQuery.docs.isNotEmpty;
      print('Story $storyId like status: $isLiked (found ${likeQuery.docs.length} documents)');
      
      if (likeQuery.docs.isNotEmpty) {
        print('Found like document: ${likeQuery.docs.first.data()}');
      }
      
      print('=== END LIKE STATUS CHECK ===');
      return isLiked;
    } catch (e) {
      print('Error checking if story liked: $e');
      return false;
    }
  }

  Future<List<String>> getLikedStoryIds() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return [];

      final likeQuery = await firestore
          .collection('stories_likes')
          .where('likedUserId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true) // En son beğenilen en üstte
          .get();

      return likeQuery.docs.map((doc) => doc.data()['likedStoryId'] as String).toList();
    } catch (e) {
      print('Error getting liked story IDs: $e');
      return [];
    }
  }
}
