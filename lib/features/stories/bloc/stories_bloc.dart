import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/bloc/stories_state.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class StoriesBloc extends HydratedBloc<StoriesEvent, StoriesState> {
  final StoriesRepository _storiesRepository;
  StoriesModel _model = StoriesModel.empty;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StoriesBloc({required StoriesRepository repo})
      : _storiesRepository = repo,
        super(StoriesInitial()) {
    //-----------for Stories image-----------------------
    on<StoriesImage>((StoriesImage event, Emitter<StoriesState> emit) async {
      try {
        final image = await _storiesRepository.addStoriesImageToCloudinary(event.imageFile);
        if (image != null) {
          final id = await _auth.currentUser!.uid;
          Set<String> images = {};
          Set<DateTime> date = {DateTime.now()};
          images.add(image);
          _model = _model.copyWith(uid: id);
          _model = _model.copyWith(userName: event.name);
          _model = _model.copyWith(userImg: event.img);
          _model = _model.copyWith(createdDate: date.toList());
          _model = _model.copyWith(containUrl: images.toList());
          await _storiesRepository.uploadStoriesToFirebase(_model);

          emit(StoriesCreateSuccess.fromState(state));
          
          // Navigate to stories page after successful upload
          Get.offAllNamed('/my-story');
        }
      } catch (e) {
        // Handle error if needed
        print('Error uploading story: $e');
      }
    });

    // ------------------------Fetching stories dataa---------------------------------
    on<StoriesFetching>((
      StoriesFetching event,
      Emitter<StoriesState> emit,
    ) async {
      try {
        final List<StoriesFetchModel> data =
            await _storiesRepository.fetchAllStoriesData();
        // Always emit the state, even if empty
        emit(StoriesState(data: data));
      } catch (e) {
        emit(
          StoriesError.fromState(
            state,
            errorMessage: EnumLocale.defaultError.name.tr,
          ),
        );
      }
    });

    // ------------------------Refresh stories data---------------------------------
    on<StoriesRefresh>((
      StoriesRefresh event,
      Emitter<StoriesState> emit,
    ) async {
      try {
        // Clear cache first
        emit(StoriesInitial());
        // Then fetch fresh data
        final List<StoriesFetchModel> data =
            await _storiesRepository.fetchAllStoriesData();
        // Always emit the state, even if empty
        emit(StoriesState(data: data));
      } catch (e) {
        emit(
          StoriesError.fromState(
            state,
            errorMessage: EnumLocale.defaultError.name.tr,
          ),
        );
      }
    });

    // ------------------------Story Like Toggle---------------------------------
    on<StoriesLikeToggle>((event, emit) async {
      try {
        final isLiked = state.likedStories[event.storyId] ?? false;
        
        if (isLiked) {
          await _storiesRepository.unlikeStory(event.storyId);
        } else {
          await _storiesRepository.likeStory(event.storyId);
        }
        
        // Update the liked status in state
        final updatedLikedStories = Map<String, bool>.from(state.likedStories);
        updatedLikedStories[event.storyId] = !isLiked;
        emit(state.copyWith(likedStories: updatedLikedStories));
      } catch (e) {
        print('Error toggling story like: $e');
      }
    });

    // ------------------------Check Story Like Status---------------------------------
    on<StoriesCheckLikeStatus>((event, emit) async {
      try {
        final isLiked = await _storiesRepository.hasLikedStory(event.storyId);
        final updatedLikedStories = Map<String, bool>.from(state.likedStories);
        updatedLikedStories[event.storyId] = isLiked;
        emit(state.copyWith(likedStories: updatedLikedStories));
        
        debugPrint('Checked like status for story ${event.storyId}: $isLiked');
        debugPrint('Updated liked stories map: $updatedLikedStories');
      } catch (e) {
        print('Error checking story like status: $e');
      }
    });

    // ------------------------Fetch Liked Stories---------------------------------
    on<StoriesFetchLikedStories>((event, emit) async {
      try {
        final likedStoryIds = await _storiesRepository.getLikedStoryIds();
        final allStories = await _storiesRepository.fetchAllStoriesData();
        
        // Filter stories that are liked by current user
        final likedStories = allStories
            .where((story) => story.documentId != null && 
                likedStoryIds.contains(story.documentId))
            .toList();
        
        emit(state.copyWith(likedStoriesList: likedStories));
      } catch (e) {
        print('Error fetching liked stories: $e');
      }
    });
  }

  // Method to clear cached data
  void clearCache() {
    emit(StoriesInitial());
  }

  @override
  StoriesState? fromJson(Map<String, dynamic> json) {
    try {
      final data = (json['data'] as List)
          .map((e) => e == null ? null : StoriesFetchModel.fromJson(e))
          .whereType<StoriesFetchModel>()
          .toList();
      return StoriesState(data: data);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(StoriesState state) {
    try {
      return {
        'data': state.data.map((e) => e.toJson()).toList(),
      };
    } catch (e) {
      return null;
    }
  }
}
