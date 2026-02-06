import 'dart:io';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/model/message_model.dart';
import 'package:afriqueen/features/chat/model/message_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';

import '../../../common/constant/constant_strings.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<ChatModel>> getChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
        );
      }).toList();
    });
  }

  Stream<List<ChatModel>> getRegularChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final isRequest = data['isRequest'] as bool? ?? false;
        
        // If it's not a request chat, include it
        if (!isRequest) return true;
        
        // If it's a request chat, check if current user sent the last message
        final lastMessageSenderId = data['lastMessageSenderId'] as String?;
        if (lastMessageSenderId == currentUserId) {
          return true; // Include in regular chats if current user sent last message
        }
        
        return false; // Exclude from regular chats
      }).map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
        );
      }).toList();
    });
  }

  Stream<List<ChatModel>> getRequestChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('isRequest', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
          status: data['status'] as String?,
          lastMessageSenderId: data['lastMessageSenderId'] as String?,
        );
      }).toList();
    });
  }

  Future<List<ChatModel>> getRequestChats() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .where('isRequest', isEqualTo: true)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs.where((doc) {
        final data = doc.data();
        // Only include request chats where current user did NOT send the last message
        final lastMessageSenderId = data['lastMessageSenderId'] as String?;
        return lastMessageSenderId != currentUserId;
      }).map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting request chats: $e');
      return [];
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Be tolerant: support both 'text' and 'MessageType.text' storage formats
        final dynamic rawType = data['type'];
        if (rawType is String && !rawType.startsWith('MessageType.')) {
          data['type'] = 'MessageType.' + rawType;
        }
        data['id'] = data['id'] ?? doc.id;
        return MessageModel.fromMap(data);
      }).toList();
    });
  }

  Future<bool> isUserBlocked(String userId, String otherUserId) async {
    try {
      final blockQuery = await _firestore
          .collection('blocks')
          .where('blockerId', isEqualTo: userId)
          .where('blockedUserId', isEqualTo: otherUserId)
          .get();

      return blockQuery.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    required MessageType type,
    File? imageFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if the sender is blocked by the receiver
      final isBlocked = await isUserBlocked(user.uid, receiverId);
      if (isBlocked) {
        throw Exception('You cannot send messages to this user. You have been blocked.');
      }

      String? imageUrl;
      String? audioUrl;
      int? audioDuration;

      if (type == MessageType.image && imageFile != null) {
        imageUrl = await _uploadImage(imageFile);
      } else if (type == MessageType.voice) {
        final audioFile = imageFile; // content is always the file path
        if (audioFile == null) throw Exception('Audio file is null');
        debugPrint('Uploading audio file at path: $content');
        audioUrl = await _uploadAudio(audioFile);
        debugPrint('Audio uploaded to Cloudinary. URL: $audioUrl');
        final audioPlayer = AudioPlayer();
        await audioPlayer.setFilePath(audioFile.path);
        audioDuration = (await audioPlayer.duration)?.inSeconds;
        await audioPlayer.dispose();
        final message = MessageModel(
          id: const Uuid().v4(),
          senderId: user.uid,
          receiverId: receiverId,
          // Save only the Cloudinary URL
          timestamp: DateTime.now(),
          type: type,
          audioUrl: audioUrl,
          audioDuration: audioDuration,
          content: '',
        );
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .doc(message.id)
            .set(message.toMap());

        // Update last message in chat document
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': message.content,
          'lastMessageTime': message.timestamp,
          'lastMessageSenderId': user.uid,
        });

        return;
      }
      // For text and image messages – store in the same format as existing docs
      final messageId = const Uuid().v4();
      final now = DateTime.now();
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': user.uid,
        'receiverId': receiverId,
        'content': content,
        'timestamp': Timestamp.fromDate(now),
        // Store type as "MessageType.text" style as per sample
        'type': type.toString(),
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'audioDuration': audioDuration,
        'duration': null,
        'isRead': false,
        'isUploaded': true,
        'tempId': null,
      });

      // Update last message in chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'lastMessageSenderId': user.uid,
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final _cloudinary = CloudinaryPublic(
        AppStrings.cloudName,
        AppStrings.uploadPreset,
      );
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'afriqueen/images',
          publicId: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<String> _uploadAudio(File audioFile) async {
    try {
      final cloudinary =
          CloudinaryPublic(AppStrings.cloudName, AppStrings.uploadPreset);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioFile.path,
          resourceType: CloudinaryResourceType.Video,
          folder: 'afriqueen/audio',
          publicId: 'audio_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      debugPrint('Cloudinary upload response: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading audio to Cloudinary: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  // Future<String> uploadVoiceMessage(String audioPath) async {
  //   final file = File(audioPath);
  //   final fileName =
  //       'voice_messages/${DateTime.now().millisecondsSinceEpoch}${path.extension(audioPath)}';
  //   final ref = _storage.ref().child(fileName);
  //
  //   await ref.putFile(file);
  //   return await ref.getDownloadURL();
  // }

  Future<bool> _hasSentMessage(String senderId, String receiverId) async {
    try {
      // Check if senderId has sent a message to receiverId in any chat
      final chatQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: senderId)
          .get();
      for (var chatDoc in chatQuery.docs) {
        final chatData = chatDoc.data();
        final participants = List<String>.from(chatData['participants'] ?? []);
        if (participants.contains(receiverId)) {
          final messagesQuery = await _firestore
              .collection('chats')
              .doc(chatDoc.id)
              .collection('messages')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .limit(1)
              .get();
          if (messagesQuery.docs.isNotEmpty) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking if user has sent message: $e');
      return false;
    }
  }

  Future<String> createOrGetChat(
      String otherUserId, Map<String, dynamic> otherUserInfo) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      if (otherUserId.isEmpty) throw Exception('Other user ID cannot be empty');
      if (otherUserInfo['id']?.isEmpty ?? true)
        throw Exception('User info ID cannot be empty');

      // Get current user's profile information from Firestore
      final querySnapshot = await _firestore
          .collection('user')
          .where('id', isEqualTo: currentUserId)
          .limit(1)
          .get();
      
      Map<String, dynamic> currentUserInfo = {
        'id': currentUserId,
        'name': '',
        'photoUrl': '',
      };
      
      if (querySnapshot.docs.isNotEmpty) {
        final currentUserData = querySnapshot.docs.first.data();
        currentUserInfo = {
          'id': currentUserId,
          'name': currentUserData['pseudo'],
          'photoUrl': currentUserData['imgURL'],
        };
      } else {
        // Fallback to Firebase Auth data if user document doesn't exist
        currentUserInfo = {
          'id': currentUserId,
          'name': _auth.currentUser?.displayName ?? '',
          'photoUrl': _auth.currentUser?.photoURL ?? '',
        };
      }

      // Check if chat already exists
      final existingChat = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingChat.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(otherUserId)) {
          // Update participant info if chat exists but info might be outdated
          await _firestore.collection('chats').doc(doc.id).update({
            'participantInfo': {
              currentUserId: currentUserInfo,
              otherUserId: otherUserInfo,
            },
          });
          return doc.id;
        }
      }

      // Check if the recipient (otherUserId) has liked the sender (currentUserId)
      final recipientHasLikedSender = await _checkIfUserLiked(currentUserId, otherUserId);
      // Check if the recipient (otherUserId) has sent a message to the sender (currentUserId)
      final recipientHasSentMessage = await _hasSentMessage(otherUserId, currentUserId);

      // Determine if this chat should be a request
      debugPrint('recipientHasLikedSender: $recipientHasLikedSender'+ ' recipientHasSentMessage: $recipientHasSentMessage');
      final isRequest = !(recipientHasLikedSender || recipientHasSentMessage);

      // Create new chat
      final chatData = {
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'participants': [currentUserId, otherUserId],
        'participantInfo': {
          currentUserId: currentUserInfo,
          otherUserId: otherUserInfo,
        },
        'unreadCount': {
          currentUserId: 0,
          otherUserId: 0,
        },
        'isRequest': isRequest,
        'isDeclined': false,
      };

      final chatRef = await _firestore.collection('chats').add(chatData);
      return chatRef.id;
    } catch (e) {
      debugPrint('Error in createOrGetChat: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      // Delete message from Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // If message has media, delete from storage
      final messageDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (messageDoc.exists) {
        final message = MessageModel.fromJson(messageDoc.data()!);

        // Delete image if exists
        // if (message.imageUrl != null) {
        //   final imageRef = _storage.refFromURL(message.imageUrl!);
        //   await imageRef.delete();
        // }
        //
        // // Delete audio if exists
        // if (message.audioUrl != null) {
        //   final audioRef = _storage.refFromURL(message.audioUrl!);
        //   await audioRef.delete();
        // }
      }

      // Update last message in chat document
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messagesSnapshot.docs.isNotEmpty) {
        final lastMessage = messagesSnapshot.docs.first.data();
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': lastMessage['content'],
          'lastMessageTime': lastMessage['timestamp'],
          'lastMessageSenderId': lastMessage['senderId'],
        });
      } else {
        // If no messages left, clear the last message
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': null,
          'lastMessageTime': null,
          'lastMessageSenderId': null,
        });
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return MessageModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      rethrow;
    }
  }

  Future<void> sendVoiceMessage({
    required String chatId,
    required String receiverId,
    required File audioFile,
    required int duration,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a temporary message ID
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create initial message with temporary ID
      final initialMessage = MessageModel(
        id: tempMessageId,
        senderId: user.uid,
        receiverId: receiverId,
        content: '',
        timestamp: DateTime.now(),
        type: MessageType.voice,
        audioUrl: null,
        audioDuration: duration,
        isUploaded: false,
        tempId: tempMessageId,
      );

      // Add initial message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(tempMessageId)
          .set(initialMessage.toMap());

      // Upload audio to Cloudinary
      final audioUrl = await _uploadAudio(audioFile);

      // Create final message with Cloudinary URL
      final finalMessage = MessageModel(
        id: tempMessageId,
        senderId: user.uid,
        receiverId: receiverId,
        content: '',
        timestamp: DateTime.now(),
        type: MessageType.voice,
        audioUrl: audioUrl,
        audioDuration: duration,
        isUploaded: true,
      );

      // Update message in Firestore with final data
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(tempMessageId)
          .set(finalMessage.toMap());

      // Update chat metadata
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '🎤 Voice message',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSenderId': user.uid,
        'unreadCount.${receiverId}': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error sending voice message: $e');
      rethrow;
    }
  }

  Future<bool> hasUserReported(String reportedUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final reportQuery = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: currentUserId)
          .where('reportedUserId', isEqualTo: reportedUserId)
          .get();

      return reportQuery.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if user has reported: $e');
      return false;
    }
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String chatId,
    required String reason,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Check if user has already reported
      final hasReported = await hasUserReported(reportedUserId);
      if (hasReported) {
        throw Exception('You have already reported this user');
      }

      // Add report to Firestore
      await _firestore.collection('reports').add({
        'reporterId': currentUserId,
        'reportedUserId': reportedUserId,
        'chatId': chatId,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reporting user: $e');
      rethrow;
    }
  }

  // Get received request chats (where current user is recipient)
  Stream<List<ChatModel>> getReceivedRequestChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('isRequest', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        // Only include request chats where current user did NOT send the last message
        final lastMessageSenderId = data['lastMessageSenderId'] as String?;
        return lastMessageSenderId != currentUserId;
      }).map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
          status: data['status'] as String?,
          lastMessageSenderId: data['lastMessageSenderId'] as String?,
        );
      }).toList();
    });
  }

  // Get sent request chats (where current user is sender)
  Stream<List<ChatModel>> getArchivedChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    // First get archived user IDs from user->archive->main
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('archive')
        .doc('main')
        .snapshots()
        .asyncMap((archiveDoc) async {
      if (!archiveDoc.exists) return <ChatModel>[];
      
      final archiveData = archiveDoc.data();
      final archivedUserIds = List<String>.from(archiveData?['archiveId'] ?? []);
      
      if (archivedUserIds.isEmpty) return <ChatModel>[];
      
      // Get chats where current user is participant
      final chatsQuery = await _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      
      // Filter chats that have archived users as participants
      final archivedChats = chatsQuery.docs.where((doc) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        
        // Check if any participant is in archived list
        return participants.any((participantId) => 
            participantId != currentUserId && archivedUserIds.contains(participantId));
      }).toList();
      
      return archivedChats.map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
          status: data['status'] as String?,
          lastMessageSenderId: data['lastMessageSenderId'] as String?,
        );
      }).toList();
    });
  }

  Stream<List<ChatModel>> getSentRequestChatsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('isRequest', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        // Only include request chats where current user DID send the last message
        final lastMessageSenderId = data['lastMessageSenderId'] as String?;
        return lastMessageSenderId == currentUserId;
      }).map((doc) {
        final data = doc.data();
        final unreadCounts =
            Map<String, dynamic>.from(data['unreadCount'] ?? {});
        final unreadCount = unreadCounts[currentUserId] as int? ?? 0;

        return ChatModel(
          id: doc.id,
          participants: List<Map<String, dynamic>>.from(
              data['participantInfo']?.values ?? []),
          lastMessage: data['lastMessage'] as String?,
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unreadCount,
          isRequest: data['isRequest'] as bool? ?? false,
          isDeclined: data['isDeclined'] as bool? ?? false,
          status: data['status'] as String?,
          lastMessageSenderId: data['lastMessageSenderId'] as String?,
        );
      }).toList();
    });
  }

  // Message Requests Methods
  Stream<List<MessageRequestModel>> getMessageRequestsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('messageRequests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isAccepted', isEqualTo: false)
        .where('isRejected', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MessageRequestModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> sendMessageRequest({
    required String receiverId,
    required String content,
    required String receiverName,
    String? receiverPhotoUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Get current user's profile information from Firestore
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      String senderName = '';
      String? senderPhotoUrl;
      
      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data()!;
        senderName = currentUserData['name'] ?? _auth.currentUser?.displayName ?? '';
        senderPhotoUrl = currentUserData['imgURL'] ?? _auth.currentUser?.photoURL;
      } else {
        // Fallback to Firebase Auth data if user document doesn't exist
        senderName = _auth.currentUser?.displayName ?? '';
        senderPhotoUrl = _auth.currentUser?.photoURL;
      }

      // Check if the receiver has liked the sender
      final hasLiked = await _checkIfUserLiked(receiverId, currentUserId);
      debugPrint('Has liked result: $hasLiked');
      
      if (hasLiked) {
        debugPrint('Creating direct chat because user has liked');
        // If receiver has liked sender, create a regular chat instead
        final chatId = await createOrGetChat(
          receiverId,
          {
            'id': receiverId,
            'name': receiverName,
            'photoUrl': receiverPhotoUrl,
          },
        );
        
        // Send message directly to chat
        await sendMessage(
          chatId: chatId,
          receiverId: receiverId,
          content: content,
          type: MessageType.text,
        );
      } else {
        debugPrint('Creating message request because user has not liked');
        // Create message request
        final request = MessageRequestModel(
          id: const Uuid().v4(),
          senderId: currentUserId,
          receiverId: receiverId,
          content: content,
          timestamp: DateTime.now(),
          senderName: senderName,
          senderPhotoUrl: senderPhotoUrl,
        );

        await _firestore
            .collection('messageRequests')
            .doc(request.id)
            .set(request.toMap());
        debugPrint('Message request created with ID: ${request.id}');
      }
    } catch (e) {
      debugPrint('Error sending message request: $e');
      rethrow;
    }
  }

  Future<void> acceptMessageRequest(String requestId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Get the request
      final requestDoc = await _firestore
          .collection('messageRequests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) throw Exception('Request not found');

      final request = MessageRequestModel.fromFirestore(requestDoc);

      // Get current user's profile information from Firestore
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();
      
      String currentUserName = '';
      String? currentUserPhotoUrl;
      
      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data()!;
        currentUserName = currentUserData['name'] ?? _auth.currentUser?.displayName ?? '';
        currentUserPhotoUrl = currentUserData['imgURL'] ?? _auth.currentUser?.photoURL;
      } else {
        // Fallback to Firebase Auth data if user document doesn't exist
        currentUserName = _auth.currentUser?.displayName ?? '';
        currentUserPhotoUrl = _auth.currentUser?.photoURL;
      }

      // Create or get chat with updated user info
      final chatId = await createOrGetChat(
        request.senderId,
        {
          'id': request.senderId,
          'name': request.senderName,
          'photoUrl': request.senderPhotoUrl,
        },
      );

      // Send the original message to the chat
      await sendMessage(
        chatId: chatId,
        receiverId: request.senderId,
        content: request.content,
        type: MessageType.text,
      );

      // Mark request as accepted
      await _firestore
          .collection('messageRequests')
          .doc(requestId)
          .update({
        'isAccepted': true,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error accepting message request: $e');
      rethrow;
    }
  }

  Future<bool> _checkIfUserLiked(String userId, String otherUserId) async {
    try {
      // For now, always return false to test message requests
      // TODO: Implement proper like checking when like system is ready
      debugPrint('Checking if user $otherUserId liked user $userId');
      
      final likeQuery = await _firestore
          .collection('likes')
          .where('likerId', isEqualTo: otherUserId)
          .where('likedUserId', isEqualTo: userId)
          .get();

      final hasLiked = likeQuery.docs.isNotEmpty;
      debugPrint('Has liked: $hasLiked');
      return hasLiked;
    } catch (e) {
      debugPrint('Error checking if user liked: $e');
      // For testing, return false so all messages go to requests
      return false;
    }
  }

  Future<void> updateChatRequestStatus(String chatId, bool isRequest) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isRequest': isRequest,
        'isDeclined': true
      });
    } catch (e) {
      debugPrint('Error updating chat request status: $e');
      rethrow;
    }
  }

  Future<void> updateChatStatus(String chatId, {required String status}) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'status': status,
        // Ensure declined flag reflects status
        'isDeclined': status == 'REJECTED' || status == 'DECLINED',
      });
    } catch (e) {
      debugPrint('Error updating chat status: $e');
      rethrow;
    }
  }

  Future<void> addToBlockCollection(String blockerId, String blockedUserId) async {
    try {
      await _firestore.collection('blocks').add({
        'blockerId': blockerId,
        'blockedUserId': blockedUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding to block collection: $e');
      rethrow;
    }
  }

  Future<void> archiveRejectedProfile(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw Exception('User not authenticated');

      // Add to archive collection
      final archiveRepository = ArchiveRepository();
      await archiveRepository.addArchive(otherUserId);

      // Optionally, you can also add to block collection if needed
      // await addToBlockCollection(currentUserId, otherUserId);
    } catch (e) {
      debugPrint('Error archiving rejected profile: $e');
      rethrow;
    }
  }
}
