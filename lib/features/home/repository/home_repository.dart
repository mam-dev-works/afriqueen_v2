import 'package:afriqueen/features/home/model/home_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/location/location.dart';
import '../../../services/permissions/permission_handler.dart';
import '../../../services/invisible_mode_service.dart';

//----------------Fetching current   profile data of all user
class HomeRepository {
  final FirebaseFirestore firebaseFirestore;
  final InvisibleModeService _invisibleModeService = InvisibleModeService();
  
  HomeRepository({FirebaseFirestore? firestore})
    : firebaseFirestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Placemark>?> updateLocation() async {
    bool isGranted = await AppPermission.requestLocationPermission();

    if (!isGranted) {
      await AppPermission.requestLocationPermission();
      return null;
    } else {
      try {
        final Position position = await UserLocation.determinePosition();
        final List<Placemark> placemarks = await UserLocation.geoCoding(position);
        if (placemarks.isEmpty) return null;
        
        final placemark = placemarks.first;
        final city = placemark.locality;
        final country = placemark.country;
        final uid = FirebaseAuth.instance.currentUser!.uid;
        debugPrint('City: $city, Country: $country');

        // Find user document by ID field and update location
        final userQuery = await firebaseFirestore
            .collection('user')
            .where('id', isEqualTo: uid)
            .get();

        if (userQuery.docs.isNotEmpty) {
          await userQuery.docs.first.reference.update({
            'city': city,
            'country': country
          });
        } else {
          debugPrint('User document not found with ID: $uid');
        }

        return placemarks;
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<List<HomeModel>> fetchAllExceptCurrentUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      print('HomeRepository: Fetching users for current user: $uid');

      // Fetch all profiles where 'id' is not equal to current user's uid
      print('HomeRepository: Querying user collection with uid: $uid');
      
      // Try alternative approach if isNotEqualTo doesn't work
      final snapshot =
          await firebaseFirestore
              .collection('user')
              .get();
      
      print('HomeRepository: Query returned ${snapshot.docs.length} documents');
      
      // Filter out current user manually - check both document ID and 'id' field
      final filteredDocs = snapshot.docs.where((doc) {
        final docId = doc.data()['id'] as String? ?? '';
        final documentId = doc.id;
        // Exclude if either the document ID or the 'id' field matches current user's UID
        final shouldInclude = docId != uid && documentId != uid;
        if (!shouldInclude) {
          print('HomeRepository: Excluding user - Document ID: $documentId, Data ID: $docId, Current UID: $uid');
        }
        return shouldInclude;
      }).toList();
      print('HomeRepository: After filtering current user: ${filteredDocs.length} documents');
      print('HomeRepository: After filtering current user: ${filteredDocs.length} documents');

      // Fetch current user's profile to determine their characteristics
      HomeModel? currentUserModel;
      try {
        currentUserModel = await fetchUserById(uid);
      } catch (_) {}

      // Derive current viewer characteristics
      final String viewerSex = currentUserModel?.gender ?? '';
      final String viewerOrientation = currentUserModel?.orientation ?? '';
      final String viewerProfileType = (currentUserModel?.isElite ?? false) ? 'Élite' : 'Classique';

      final users = filteredDocs.map((doc) {
        print('HomeRepository: Processing document: ${doc.id}');
        final data = doc.data();
        print('HomeRepository: Document data: $data');
        
        // Debug: Check specific fields
        print('HomeRepository: Has photos field: ${data.containsKey('photos')}');
        if (data.containsKey('photos')) {
          print('HomeRepository: Photos field: ${data['photos']}');
          print('HomeRepository: Photos field type: ${data['photos'].runtimeType}');
          if (data['photos'] is List) {
            print('HomeRepository: Photos list length: ${(data['photos'] as List).length}');
            print('HomeRepository: Photos list content: ${data['photos']}');
          }
        }
        print('HomeRepository: Has name field: ${data.containsKey('name')}');
        if (data.containsKey('name')) {
          print('HomeRepository: Name field: ${data['name']}');
        }
        print('HomeRepository: Has gender field: ${data.containsKey('gender')}');
        if (data.containsKey('gender')) {
          print('HomeRepository: Gender field: ${data['gender']}');
        }
        
        final candidate = HomeModel.fromMap(data);
        return candidate;
      }).toList();
      print('HomeRepository: Fetched ${users.length} users from Firestore');
      
      // Debug: Print first few users
      if (users.isNotEmpty) {
        final firstUser = users.first;
        final firstPhoto = firstUser.photos.isNotEmpty ? firstUser.photos.first : 'No photo';
        print('HomeRepository: First user - ID: ${firstUser.id}, Pseudo: ${firstUser.pseudo}, imgURL: $firstPhoto');
      }
      
      // Apply invisibility filtering: remove users who decided to be invisible to the current viewer
      final filteredByInvisibility = users.where((user) {
        final hidesFromType = user.invisibleToProfileTypes.contains(viewerProfileType);
        final hidesFromSex = user.invisibleToSexes.contains(viewerSex);
        final hidesFromOrientation = user.invisibleToOrientations.contains(viewerOrientation);
        final isInvisibleToViewer = hidesFromType || hidesFromSex || hidesFromOrientation;
        return !isInvisibleToViewer;
      }).toList();

      // Filter out users in invisible mode (unless we have interacted with them)
      final List<HomeModel> filteredByInvisibleMode = [];
      for (final user in filteredByInvisibility) {
        // Additional safety check: Ensure current user is never included
        if (user.id == uid) {
          print('HomeRepository: Excluding current user from results - User ID: ${user.id}, Current UID: $uid');
          continue;
        }
        
        final isInvisible = await _invisibleModeService.isUserInvisible(user.id);
        if (!isInvisible) {
          // User is not in invisible mode, include them
          filteredByInvisibleMode.add(user);
        } else {
          // User is in invisible mode, check if we have interacted
          final hasInteracted = await _invisibleModeService.hasInteractedWith(user.id);
          if (hasInteracted) {
            // We have interacted, include them
            filteredByInvisibleMode.add(user);
          }
          // If no interaction, exclude them
        }
      }

      // Final safety check: Filter out any remaining current user profiles
      final finalFiltered = filteredByInvisibleMode.where((user) {
        final isCurrentUser = user.id == uid;
        if (isCurrentUser) {
          print('HomeRepository: Final filter - Excluding current user: ${user.id}');
        }
        return !isCurrentUser;
      }).toList();

      return finalFiltered;
    } catch (e) {
      // Don't print "Bad state: No element" errors - they're handled gracefully
      if (e.toString().contains('Bad state: No element')) {
        // Return empty list instead of throwing
        return [];
      }
      print('HomeRepository Error: $e');
      rethrow;
    }
  }

  Future<HomeModel?> fetchUserById(String userId) async {
    try {
      final snapshot = await firebaseFirestore
          .collection('user')
          .where('id', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return HomeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('HomeRepository Error fetching user by ID: $e');
      return null;
    }
  }

  Future<List<HomeModel>> findUsersForBlock({
    required List<String> selectedProfileTypes,
    required List<String> selectedSexes,
    required List<String> selectedOrientations,
    required RangeValues ageRange,
    List<String>? selectedMaritalStatuses,
    List<String>? selectedMainInterests,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final snapshot = await firebaseFirestore.collection('user').get();

      final others = snapshot.docs.where((doc) => (doc.data()['id'] as String? ?? '') != uid).toList();

      final Set<String> profileTypes = selectedProfileTypes.map((e) => e).toSet();
      final Set<String> sexes = selectedSexes.map((e) => e).toSet();
      final Set<String> orientations = selectedOrientations.map((e) => e).toSet();

      final List<HomeModel> matches = [];
      for (final d in others) {
        final data = d.data();
        final hm = HomeModel.fromMap(data);

        // profile type
        final String userType = (hm.isElite ? 'Élite' : 'Classique');
        if (profileTypes.isNotEmpty && !profileTypes.contains(userType)) continue;

        // sex
        if (sexes.isNotEmpty && !sexes.contains(hm.gender)) continue;

        // orientation
        if (orientations.isNotEmpty && !orientations.contains(hm.orientation)) continue;

        // age
        final int age = (data['age'] as num?)?.toInt() ?? 0;
        if (ageRange.start > 0 || ageRange.end > 0) {
          if (!(age >= ageRange.start.round() && age <= ageRange.end.round())) continue;
        }

        // marital status (optional)
        if (selectedMaritalStatuses != null && selectedMaritalStatuses.isNotEmpty) {
          final status = (data['relationshipStatus'] as String?) ?? '';
          if (!selectedMaritalStatuses.contains(status)) continue;
        }

        // main interests (optional, intersects)
        if (selectedMainInterests != null && selectedMainInterests.isNotEmpty) {
          final List<dynamic> mi = (data['mainInterests'] as List<dynamic>?) ?? const [];
          final Set<String> miSet = mi.map((e) => e.toString()).toSet();
          if (miSet.intersection(selectedMainInterests.toSet()).isEmpty) continue;
        }

        matches.add(hm);
      }

      return matches;
    } catch (e) {
      debugPrint('findUsersForBlock error: $e');
      rethrow;
    }
  }

  Future<void> updateCurrentUserInvisibility({
    required List<String> invisibleToProfileTypes,
    required List<String> invisibleToSexes,
    required List<String> invisibleToOrientations,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userQuery = await firebaseFirestore
        .collection('user')
        .where('id', isEqualTo: uid)
        .get();
    if (userQuery.docs.isEmpty) return;

    await userQuery.docs.first.reference.update({
      'invisibleToProfileTypes': invisibleToProfileTypes,
      'invisibleToSexes': invisibleToSexes,
      'invisibleToOrientations': invisibleToOrientations,
    });
  }
}
