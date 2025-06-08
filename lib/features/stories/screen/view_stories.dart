import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_story_view/flutter_story_view.dart';
import 'package:flutter_story_view/models/story_item.dart';
import 'package:get/get.dart';

// ----------------------------View Stories-----------------------------------------------
class ViewStories extends StatefulWidget {
  const ViewStories({super.key, required this.data});
  final StoriesFetchModel data;

  @override
  State<ViewStories> createState() => _ViewStoriesState();
}

class _ViewStoriesState extends State<ViewStories> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
            child: Stack(
          children: [
            FlutterStoryView(
              showReplyButton: false,
              indicatorPadding: REdgeInsets.only(top: 30.h),
              storyItems: widget.data.containUrl.map((imgUrl) {
                return StoryItem(
                    url: imgUrl, type: StoryItemType.image, duration: 4);
              }).toList(),

              onComplete: () {
                Get.back();
              }, // called when stories completed
              onPageChanged: (index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      currentIndex = index;
                    });
                  }
                });
              },
              // returns current page index
              indicatorColor: Colors.grey[500],
              indicatorHeight: 2,
              indicatorValueColor: Colors.white,
            ),
            Positioned(
                top: 38.h,
                left: 10.w,
                child: Row(
                  spacing: 10.w,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AdvancedAvatar(
                      foregroundDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.floralWhite,
                        shape: BoxShape.circle,
                      ),
                      image: CachedNetworkImageProvider(widget.data.userImg),
                      size: 40.r,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.userName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: AppColors.floralWhite),
                        ),
                        Text(
                          Seniority.formatStoriesTime(
                              widget.data.createdDate[currentIndex]),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: AppColors.floralWhite),
                        )
                      ],
                    )
                  ],
                ))
          ],
        )),
      ),
    );
  }
}
