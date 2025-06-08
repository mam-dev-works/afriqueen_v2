import 'package:afriqueen/common/widgets/shimmer_effect.dart';
import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_event.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/features/profile/repository/profile_repository.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/bloc/stories_state.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:afriqueen/features/stories/screen/view_stories.dart';
import 'package:afriqueen/features/stories/widgets/stories_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: MultiRepositoryProvider(
            providers: [
          RepositoryProvider(create: (context) => ProfileRepository()),
          RepositoryProvider(create: (context) => StoriesRepository()),
        ],
            child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) =>
                        ProfileBloc(repo: context.read<ProfileRepository>())
                          ..add(ProfileFetch()),
                  ),
                  BlocProvider(
                    create: (context) =>
                        StoriesBloc(repo: context.read<StoriesRepository>())
                          ..add(StoriesFetching()),
                  ),
                ],
                child: BlocSelector<StoriesBloc, StoriesState,
                    List<StoriesFetchModel>>(
                  selector: (state) => state.data,
                  builder: (context, data) {
                    final profile = context.select<ProfileBloc, ProfileModel>(
                      (bloc) => bloc.state.data,
                    );
                    final hasValidUrl = profile.imgURL.isNotEmpty &&
                        Uri.tryParse(profile.imgURL)?.hasAbsolutePath == true;
                    final String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;

                    final int currentUserIndexInData =
                        data.indexWhere((story) => story.id == currentUserId);

                    final bool hasCurrentUserStory =
                        currentUserIndexInData != -1;

                    final int visibleStoriesCount =
                        hasCurrentUserStory ? data.length - 1 : data.length;

                    return ShimmerScreen(
                      enabled: data.isEmpty ? true : false,
                      child: SizedBox(
                        height: 85.h,
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemCount: 1 + visibleStoriesCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 1.2,
                                  crossAxisSpacing: 0),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // ----------------- "Add Story" Avatar -------------------
                              return GestureDetector(
                                onTap: () {
                                  if (hasCurrentUserStory) {
                                    Get.to(() => ViewStories(
                                        data: data[currentUserIndexInData]));
                                  }
                                },
                                //---------------------Current user Stories--------------------------------
                                child: OwnStories(
                                    hasValidUrl: hasValidUrl, profile: profile),
                              );
                            }

                            // Adjust index to skip current user's story
                            int adjustedIndex = index - 1;
                            if (hasCurrentUserStory &&
                                adjustedIndex >= currentUserIndexInData) {
                              adjustedIndex += 1;
                            }

                            final story = data[adjustedIndex];

                            final hasValidOtherUserImage = story
                                    .userImg.isNotEmpty &&
                                Uri.tryParse(story.userImg)?.hasAbsolutePath ==
                                    true;
                            //---------------------Other user Stories--------------------------------
                            return GestureDetector(
                              onTap: () =>
                                  Get.to(() => ViewStories(data: story)),
                              child: OtherUserStories(
                                  hasValidOtherUserImage:
                                      hasValidOtherUserImage,
                                  story: story),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ))));
  }
}
