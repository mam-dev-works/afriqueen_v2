import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/seniority.dart';
import 'package:afriqueen/common/widgets/user_status.dart';
import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_state.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/logout_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../common/constant/constant_strings.dart';
import 'package:afriqueen/common/localization/language/en_us.dart';
import 'package:afriqueen/common/localization/language/fr_fr.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

//----------------AppBar -----------------------
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      actions: const [],
      title: AppBarTitle(),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios_new, color: AppColors.primaryColor),
      ),
    );
  }
}

//----------------AppBar Title-----------------------
class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.pseudo,
      builder: (context, data) {
        return Text(
          data,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontSize: 25.sp),
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

//----------Description-----------------------
class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, String>(
      selector: (state) => state.data.description,
      builder: (context, data) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.description.name.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  data,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//----------------User Interests ----------------------------
class UserInterestsList extends StatelessWidget {
  const UserInterestsList({super.key});

  String _getTranslatedInterest(String interest) {
    switch (interest) {
      case 'Music':
        return EnumLocale.music.name.tr;
      case 'Creativity':
        return EnumLocale.creativity.name.tr;
      case 'Fitness':
        return EnumLocale.fitness.name.tr;
      case 'Travel':
        return EnumLocale.travel.name.tr;
      case 'Fashion':
        return EnumLocale.fashion.name.tr;
      case 'Chatting':
        return EnumLocale.chatting.name.tr;
      case 'Making New Friends':
        return EnumLocale.makingNewFriends.name.tr;
      case 'Study Buddy':
        return EnumLocale.studyBuddy.name.tr;
      case 'Movie Nights':
        return EnumLocale.movieNights.name.tr;
      case 'Coffee Hangouts':
        return EnumLocale.coffeeHangouts.name.tr;
      case 'Romantic Dates':
        return EnumLocale.romanticDates.name.tr;
      case 'Candlelight Dinners':
        return EnumLocale.candlelight.name.tr;
      case 'Sweet Surprises':
        return EnumLocale.sweet.name.tr;
      case 'Slow Dancing':
        return EnumLocale.slowDancing.name.tr;
      case 'Love Letters':
        return EnumLocale.loveLetters.name.tr;
      case 'Football':
        return EnumLocale.football.name.tr;
      case 'Yoga':
        return EnumLocale.yoga.name.tr;
      case 'Hiking':
        return EnumLocale.hiking.name.tr;
      case 'Running':
        return EnumLocale.running.name.tr;
      case 'Cycling':
        return EnumLocale.cycling.name.tr;
      case 'Foodie':
        return EnumLocale.foodie.name.tr;
      case 'Street Food':
        return EnumLocale.streetFood.name.tr;
      case 'Fine Dining':
        return EnumLocale.fineDining.name.tr;
      case 'Coffee Lover':
        return EnumLocale.coffeeLover.name.tr;
      case 'Baking':
        return EnumLocale.baking.name.tr;
      case 'Backpacking':
        return EnumLocale.backpacking.name.tr;
      case 'Road Trips':
        return EnumLocale.roadTrips.name.tr;
      case 'Solo Travel':
        return EnumLocale.soloTravel.name.tr;
      case 'Camping':
        return EnumLocale.camping.name.tr;
      case 'City Breaks':
        return EnumLocale.cityBreaks.name.tr;
      default:
        return interest;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, List>(
      selector: (state) => state.data.interests,
      builder: (context, data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                EnumLocale.interests.name.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 3,
              ),
              itemBuilder: (BuildContext context, index) {
                final interest = data[index];
                final translatedInterest = _getTranslatedInterest(interest);
                
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.3), width: 1.w),
                  ),
                  child: Center(
                    child: Text(
                      translatedInterest,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

//------------------User account age -----------------------------
class UserSeniority extends StatelessWidget {
  const UserSeniority({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, DateTime>(
      selector: (state) => state.data.createdDate,
      builder: (context, data) {
        final date = Seniority.formatJoinedTime(data);
        return Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16.r, color: AppColors.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//------------------------------------- user name , age nad city----------------------------
class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, ProfileModel>(
      selector: (state) => state.data,
      builder: (context, data) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(context, data.pseudo, EnumLocale.nameTitle.name.tr),
              Container(
                height: 24.h,
                width: 1.w,
                color: Colors.grey[300],
              ),
              _buildDetailItem(context, "${data.age}", EnumLocale.age.name.tr),
              Container(
                height: 24.h,
                width: 1.w,
                color: Colors.grey[300],
              ),
              _buildDetailItem(context, data.city, EnumLocale.city.name.tr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

//----------------------------- Profile Image-----------------------------
class ProfileImage extends StatelessWidget {
  ProfileImage({super.key});
  final auth = FirebaseAuth.instance;
  
  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, ProfileModel>(
      selector: (state) => state.data,
      builder: (context, profile) {
        final hasValidUrl = profile.imgURL.isNotEmpty && Uri.tryParse(profile.imgURL)?.hasAbsolutePath == true;
        return Padding(
          padding: EdgeInsets.only(bottom: 5.h),
          child: Container(
            height: 280.h,
            width: double.maxFinite.w,
            decoration: BoxDecoration(
              image: hasValidUrl
                  ? DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(profile.imgURL),
                    )
                  : null,
              color: AppColors.floralWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              // Elite styling
              border: profile.isElite 
                  ? Border.all(
                      color: Colors.amber,
                      width: 3.w,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8.r,
                  right: 8.r,
                  child: UserStatus(id: auth.currentUser!.uid),
                ),
                // Elite badge
                if (profile.isElite)
                  Positioned(
                    top: 8.r,
                    left: 8.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD700).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Compte élite',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto-SemiBold',
                        ),
                      ),
                    ),
                  ),
                if (!hasValidUrl)
                  Center(
                    child: Icon(
                      Icons.person,
                      size: 80.r,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --------------------- Profile Menu Section (UI) ----------------------
class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with account type and upgrade CTA
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar from profile image
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: BlocSelector<ProfileBloc, ProfileState, String>(
                    selector: (s) => s.data.imgURL,
                    builder: (context, url) {
                      final valid = url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
                      if (valid) {
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(color: AppColors.floralWhite, child: Icon(Icons.person, size: 32.r));
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EnumLocale.youAreOnClassic.name.tr, style: textTheme.bodySmall),
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.premiumPlans),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(EnumLocale.switchToPremium.name.tr, style: textTheme.bodySmall),
                            ),
                            SizedBox(width: 6.w),
                            Icon(CupertinoIcons.forward, size: 16.r),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.comprehensiveEditProfile),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7BD8E),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(EnumLocale.editMyProfileCTA.name.tr, style: textTheme.bodySmall?.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _MenuTile(title: EnumLocale.menuLanguage.name.tr),
        _InvisibleModeTile(),
        _MenuTile(title: EnumLocale.menuReferral.name.tr),
        _MenuTile(title: EnumLocale.menuRedList.name.tr),
        _MenuTile(title: EnumLocale.menuIdentityVerification.name.tr),
        _MenuTile(title: EnumLocale.menuUpgradeToPremium.name.tr),
        _MenuTile(title: EnumLocale.menuAccountStatus.name.tr),
        _MenuTile(title: EnumLocale.menuNotificationSettings.name.tr),
        _MenuTile(title: EnumLocale.menuContactUs.name.tr),
        _MenuTile(title: EnumLocale.menuInfoAndTips.name.tr),
        _MenuTile(title: EnumLocale.menuUpdateApplication.name.tr),
        _MenuTile(title: EnumLocale.menuTermsOfUseLabel.name.tr),
        _MenuTile(title: EnumLocale.menuPrivacyPolicyLabel.name.tr),
        _MenuTile(title: EnumLocale.menuSuspendMyAccount.name.tr),
        _MenuTile(title: EnumLocale.menuDeleteMyAccount.name.tr),
        _MenuTile(title: EnumLocale.menuLogout.name.tr),
      ],
    );
  }
}

class _InvisibleModeTile extends StatelessWidget {
  const _InvisibleModeTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(EnumLocale.menuInvisibleMode.name.tr),
        subtitle: Text(
          'Activer le mode invisible',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(CupertinoIcons.forward),
        dense: true,
        onTap: () => Get.toNamed(AppRoutes.invisibleMode),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  const _MenuTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == EnumLocale.menuLanguage.name.tr) {
          Get.toNamed(AppRoutes.languageSelection);
          return;
        }
        if (title == EnumLocale.menuReferral.name.tr) {
          Get.toNamed(AppRoutes.referral);
          return;
        }
        if (title == EnumLocale.menuRedList.name.tr) {
          Get.toNamed(AppRoutes.blocked);
          return;
        }
        if (title == EnumLocale.menuIdentityVerification.name.tr) {
          Get.toNamed(AppRoutes.identityVerification);
          return;
        }
        if (title == EnumLocale.menuUpgradeToPremium.name.tr ||
            title == EnumLocale.switchToPremium.name.tr) {
          Get.toNamed(AppRoutes.premiumPlans);
          return;
        }
        if (title == EnumLocale.menuContactUs.name.tr) {
          Get.toNamed(AppRoutes.contactUs);
          return;
        }
        if (title == EnumLocale.menuNotificationSettings.name.tr) {
          Get.toNamed(AppRoutes.notificationSettings);
          return;
        }
        if (title == EnumLocale.menuSuspendMyAccount.name.tr) {
          Get.toNamed(AppRoutes.suspendAccount);
          return;
        }
        if (title == EnumLocale.menuDeleteMyAccount.name.tr) {
          Get.toNamed(AppRoutes.deleteAccount);
          return;
        }
        if (title == EnumLocale.menuLogout.name.tr) {
          LogoutService.showLogoutConfirmation();
          return;
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ListTile(
          title: Text(title),
          trailing: Icon(CupertinoIcons.forward),
          dense: true,
        ),
      ),
    );
  }
}

