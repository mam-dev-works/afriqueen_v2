import 'package:afriqueen/features/archive/model/archive_model.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/blocked/repository/blocked_repository.dart';
import 'package:afriqueen/features/favorite/model/favorite_model.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/match/repository/like_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../blocked/model/blocked_model.dart';
import 'match_event.dart';
import 'match_state.dart';

class MatchBloc extends HydratedBloc<MatchEvent, MatchState> {
  final HomeRepository _homeRepository = HomeRepository();
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  final ArchiveRepository _archiveRepository = ArchiveRepository();
  final BlockedRepository _blockedRepository = BlockedRepository();
  final LikeRepository _likeRepository = LikeRepository();

  MatchBloc() : super(MatchInitial()) {
    on<MatchUsersFetched>((event, emit) async {
      // Always fetch fresh data to ensure archive/favorite filtering is up to date

      try {
        emit(Loading.fromState(state));
        final List<HomeModel?> data = await _homeRepository.fetchAllExceptCurrentUser();
        
        // Filter out profiles that are in favorites or archives
        final FavoriteModel? favData = await _favoriteRepository.fetchFavorites();
        final ArchiveModel? archiveData = await _archiveRepository.fetchArchives();
        final BlockedModel? blockedData = await _blockedRepository.fetchBlockedUsers();
        
        List<HomeModel?> filteredData = data;
        
        if (favData != null) {
          filteredData = filteredData
              .where((item) => item!.id.isNotEmpty && !favData.favId.contains(item.id))
              .toList();
        }
        
        if (archiveData != null) {
          filteredData = filteredData
              .where((item) => item!.id.isNotEmpty && !archiveData.archiveId.contains(item.id))
              .toList();
        }

        if (blockedData != null) {
          filteredData = filteredData
              .where((item) =>
          item!.id.isNotEmpty &&
              !blockedData.blockedUserId.contains(item.id))
              .toList();
        }

        // Additional safety check: Filter out current user to ensure it's never shown
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null && currentUserId.isNotEmpty) {
          filteredData = filteredData
              .where((item) {
                if (item == null) return false;
                final isCurrentUser = item.id == currentUserId || item.id.isEmpty;
                if (isCurrentUser) {
                  print('MatchBloc: Excluding current user - User ID: ${item.id}, Current UID: $currentUserId');
                }
                return !isCurrentUser;
              })
              .toList();
        }

        if (filteredData.isEmpty) {
          emit(MatchDataEmpty.fromState(state));
        } else {
          emit(state.copyWith(data: filteredData));
        }
      } catch (e) {
        // Handle "Bad state: No element" errors gracefully
        if (e.toString().contains('Bad state: No element')) {
          emit(MatchDataEmpty.fromState(state));
        } else {
          emit(Error.fromState(state, error: e.toString()));
        }
      }
    });

    on<LikeUser>((event, emit) async {
      try {
        await _likeRepository.likeUser(event.userId);
        // Update the liked status in state
        final updatedLikedUsers = Map<String, bool>.from(state.likedUsers);
        updatedLikedUsers[event.userId] = true;
        emit(state.copyWith(likedUsers: updatedLikedUsers));
      } catch (e) {
        // Handle error if needed
        debugPrint('Error liking user: $e');
      }
    });

    on<CheckLikeStatus>((event, emit) async {
      try {
        final isLiked = await _likeRepository.hasLikedUser(event.userId);
        final updatedLikedUsers = Map<String, bool>.from(state.likedUsers);
        updatedLikedUsers[event.userId] = isLiked;
        emit(state.copyWith(likedUsers: updatedLikedUsers));
      } catch (e) {
        debugPrint('Error checking like status: $e');
      }
    });

    on<UnlikeUser>((event, emit) async {
      try {
        await _likeRepository.unlikeUser(event.userId);
        // Update the liked status in state
        final updatedLikedUsers = Map<String, bool>.from(state.likedUsers);
        updatedLikedUsers[event.userId] = false;
        emit(state.copyWith(likedUsers: updatedLikedUsers));
      } catch (e) {
        debugPrint('Error unliking user: $e');
      }
    });

    on<RemoveUserFromMatch>((event, emit) async {
      try {
        // Remove user from match list
        final updatedData = state.data.where((item) => item?.id != event.userId).toList();
        emit(state.copyWith(data: updatedData));
      } catch (e) {
        debugPrint('Error removing user from match: $e');
      }
    });
  }

  @override
  MatchState? fromJson(Map<String, dynamic> json) {
    try {
      final dataList = (json['data'] as List)
          .map((e) => e == null ? null : HomeModel.fromJson(e))
          .toList();

      final likedUsersMap = (json['likedUsers'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)) ?? {};

      return MatchState(data: dataList, likedUsers: likedUsersMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(MatchState state) {
    try {
      return {
        'data': state.data.map((e) => e?.toJson()).toList(),
        'likedUsers': state.likedUsers,
      };
    } catch (e) {
      return null;
    }
  }
} 