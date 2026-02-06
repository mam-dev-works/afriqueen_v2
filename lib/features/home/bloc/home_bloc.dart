import 'package:afriqueen/features/favorite/model/favorite_model.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/bloc/home_event.dart';
import 'package:afriqueen/features/home/bloc/home_state.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/match/repository/like_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../archive/model/archive_model.dart';
import '../../archive/repository/archive_repository.dart';
import '../../blocked/model/blocked_model.dart';
import '../../blocked/repository/blocked_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository __repository;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final ArchiveRepository _archiveRepository = ArchiveRepository();
  final BlockedRepository _blockedRepository = BlockedRepository();
  final LikeRepository _likeRepository = LikeRepository();

  HomeBloc({required HomeRepository repo})
      : __repository = repo,
        super(HomeInitial()) {
    on<HomeUsersFetched>((event, emit) async {
      // Always fetch fresh data for now to avoid cache issues
      print('HomeBloc: Fetching fresh data for HomeUsersFetched...');

      try {
        emit(Loading.fromState(state));
        final List<HomeModel?> data =
            await __repository.fetchAllExceptCurrentUser();
        // Additional safety check: Filter out current user to ensure it's never shown
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        List<HomeModel?> finalData = data;
        if (currentUserId != null && currentUserId.isNotEmpty) {
          finalData = data.where((item) {
            if (item == null) return false;
            final isCurrentUser = item.id == currentUserId || item.id.isEmpty;
            if (isCurrentUser) {
              print('HomeBloc: Excluding current user - User ID: ${item.id}, Current UID: $currentUserId');
            }
            return !isCurrentUser;
          }).toList();
        }
        
        if (finalData.isEmpty) {
          emit(HomeDataIsEmpty.fromState(state));
        } else {
          emit(state.copyWith(data: finalData));
        }
      } catch (e) {
        // Handle "Bad state: No element" errors gracefully
        if (e.toString().contains('Bad state: No element')) {
          emit(HomeDataIsEmpty.fromState(state));
        } else {
          emit(Error.fromState(state, error: e.toString()));
        }
      }
    });
    on<HomeUsersProfileList>((event, emit) async {
      // Always fetch fresh data for now to avoid cache issues
      print('HomeBloc: HomeUsersProfileList event triggered');

      try {
        emit(Loading.fromState(state));

        List<HomeModel?> data;
        try {
          data = state.data.isNotEmpty
              ? state.data
              : await __repository.fetchAllExceptCurrentUser();
        } catch (e) {
          // Handle "Bad state: No element" errors gracefully
          if (e.toString().contains('Bad state: No element')) {
            emit(HomeDataIsEmpty.fromState(state));
            return;
          }
          rethrow;
        }
            
        if (data.isEmpty) {
          emit(HomeDataIsEmpty.fromState(state));
          return; // Return early if no data
        }
        
        final FavoriteModel? favData =
            await _favoriteRepository.fetchFavorites();

        final ArchiveModel? archiveData =
            await _archiveRepository.fetchArchives();

        final BlockedModel? blockedData = await _blockedRepository.fetchBlockedUsers();

        List<HomeModel?> filterData = data;
        if (favData != null) {
          filterData = filterData
              .where((item) =>
                  item!.id.isNotEmpty && !favData.favId.contains(item.id))
              .toList();
        }
        if (archiveData != null) {
          filterData = filterData
              .where((item) =>
                  item!.id.isNotEmpty &&
                  !archiveData.archiveId.contains(item.id))
              .toList();
        }
        if (blockedData != null) {
          filterData = filterData
              .where((item) =>
          item!.id.isNotEmpty &&
              !blockedData.blockedUserId.contains(item.id))
              .toList();
        }
        
        // Additional safety check: Filter out current user to ensure it's never shown
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null && currentUserId.isNotEmpty) {
          filterData = filterData
              .where((item) {
                if (item == null) return false;
                final isCurrentUser = item.id == currentUserId || item.id.isEmpty;
                if (isCurrentUser) {
                  print('HomeBloc: Excluding current user - User ID: ${item.id}, Current UID: $currentUserId');
                }
                return !isCurrentUser;
              })
              .toList();
        }
        
        // Set selectedTabIndex to 0 for New tab
        emit(state.copyWith(profileList: filterData, selectedTabIndex: 0));
      } catch (e) {
        print('HomeBloc Error: $e');
        // Handle "Bad state: No element" errors gracefully
        if (e.toString().contains('Bad state: No element')) {
          emit(HomeDataIsEmpty.fromState(state));
        } else {
          emit(Error.fromState(state, error: e.toString()));
        }
      }
    });

    on<FetchLikedUsers>((event, emit) async {
      print('HomeBloc: FetchLikedUsers event triggered');
      try {
        emit(Loading.fromState(state));
        
        // Fetch liked users from Firestore
        final likedUserIds = await _likeRepository.getLikedUserIds();
        if (likedUserIds.isNotEmpty) {
          // Fetch user details for each liked user ID
          final List<HomeModel?> likedProfiles = [];
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          for (String userId in likedUserIds) {
            // Skip current user
            if (currentUserId != null && userId == currentUserId) {
              continue;
            }
            try {
              final user = await __repository.fetchUserById(userId);
              if (user != null && user.id != currentUserId) {
                likedProfiles.add(user);
              }
            } catch (e) {
              print('Error fetching user $userId: $e');
            }
          }
          emit(state.copyWith(profileList: likedProfiles, selectedTabIndex: 1));
        } else {
          emit(state.copyWith(profileList: [], selectedTabIndex: 1));
        }
      } catch (e) {
        print('HomeBloc Error fetching liked users: $e');
        emit(Error.fromState(state, error: e.toString()));
      }
    });

    on<FetchFavoriteUsers>((event, emit) async {
      try {
        emit(Loading.fromState(state));
        
        // Fetch favorite users from Firestore
        final favoriteUsers = await _favoriteRepository.fetchFavorites();
        if (favoriteUsers != null && favoriteUsers.favId.isNotEmpty) {
          // Fetch user details for each favorite user ID
          final List<HomeModel?> favoriteProfiles = [];
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          for (String userId in favoriteUsers.favId) {
            // Skip current user
            if (currentUserId != null && userId == currentUserId) {
              continue;
            }
            try {
              final user = await __repository.fetchUserById(userId);
              if (user != null && user.id != currentUserId) {
                favoriteProfiles.add(user);
              }
            } catch (e) {
              print('Error fetching user $userId: $e');
            }
          }
          emit(state.copyWith(profileList: favoriteProfiles, selectedTabIndex: 2));
        } else {
          emit(state.copyWith(profileList: [], selectedTabIndex: 2));
        }
      } catch (e) {
        print('HomeBloc Error fetching favorite users: $e');
        emit(Error.fromState(state, error: e.toString()));
      }
    });

    on<FetchArchiveUsers>((event, emit) async {
      try {
        emit(Loading.fromState(state));
        
        // Fetch archive users from Firestore
        final archiveUsers = await _archiveRepository.fetchArchives();
        if (archiveUsers != null && archiveUsers.archiveId.isNotEmpty) {
          // Fetch user details for each archive user ID
          final List<HomeModel?> archiveProfiles = [];
          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          for (String userId in archiveUsers.archiveId) {
            // Skip current user
            if (currentUserId != null && userId == currentUserId) {
              continue;
            }
            try {
              final user = await __repository.fetchUserById(userId);
              if (user != null && user.id != currentUserId) {
                archiveProfiles.add(user);
              }
            } catch (e) {
              print('Error fetching user $userId: $e');
            }
          }
          emit(state.copyWith(profileList: archiveProfiles, selectedTabIndex: 3));
        } else {
          emit(state.copyWith(profileList: [], selectedTabIndex: 3));
        }
      } catch (e) {
        print('HomeBloc Error fetching archive users: $e');
        emit(Error.fromState(state, error: e.toString()));
      }
    });

    on<FetchAllUsers>((event, emit) async {
      try {
        emit(Loading.fromState(state));
        
        // Fetch all users except current user
        final List<HomeModel?> allUsers = await __repository.fetchAllExceptCurrentUser();
        
        // Fetch favorite and archive data to filter them out
        final FavoriteModel? favData = await _favoriteRepository.fetchFavorites();
        final ArchiveModel? archiveData = await _archiveRepository.fetchArchives();
        
        List<HomeModel?> filterData = allUsers;
        
        // Filter out profiles that are in favorites
        if (favData != null) {
          filterData = filterData
              .where((item) =>
                  item!.id.isNotEmpty && !favData.favId.contains(item.id))
              .toList();
        }
        
        // Filter out profiles that are in archive
        if (archiveData != null) {
          filterData = filterData
              .where((item) =>
                  item!.id.isNotEmpty &&
                  !archiveData.archiveId.contains(item.id))
              .toList();
        }
        
        // Additional safety check: Filter out current user to ensure it's never shown
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null && currentUserId.isNotEmpty) {
          filterData = filterData
              .where((item) {
                if (item == null) return false;
                final isCurrentUser = item.id == currentUserId || item.id.isEmpty;
                if (isCurrentUser) {
                  print('HomeBloc: Excluding current user - User ID: ${item.id}, Current UID: $currentUserId');
                }
                return !isCurrentUser;
              })
              .toList();
        }
        
        if (filterData.isEmpty) {
          emit(HomeDataIsEmpty.fromState(state));
        } else {
          emit(state.copyWith(profileList: filterData, selectedTabIndex: 4));
        }
      } catch (e) {
        print('HomeBloc Error fetching all users: $e');
        // Handle "Bad state: No element" errors gracefully
        if (e.toString().contains('Bad state: No element')) {
          emit(HomeDataIsEmpty.fromState(state));
        } else {
          emit(Error.fromState(state, error: e.toString()));
        }
      }
    });
  }
}
