import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/event/model/event_model.dart';
import 'package:afriqueen/features/event/repository/event_request_repository.dart';
import 'package:afriqueen/features/profile/model/profile_model.dart';
import 'package:afriqueen/features/profile/repository/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EventParticipationScreen extends StatefulWidget {
  final EventModel event;
  
  const EventParticipationScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventParticipationScreen> createState() => _EventParticipationScreenState();
}

class _EventParticipationScreenState extends State<EventParticipationScreen> {
  final TextEditingController _participationMessageController = TextEditingController();
  final EventRequestRepository _eventRequestRepository = EventRequestRepository();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _participationMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          EnumLocale.eventParticipationTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<ProfileModel?>(
        future: ProfileRepository().fetchUserDataById(widget.event.creatorId),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final String displayName = profile != null && (profile.toMap().containsKey('name') || profile.toMap().containsKey('surname'))
              ? '${(profile.toMap()['name'] ?? '').toString().trim()} ${(profile.toMap()['surname'] ?? '').toString().trim()}'.trim()
              : (profile?.pseudo ?? '');
          final String nameAge = (displayName.isNotEmpty ? displayName : EnumLocale.utilisateur.name.tr) + (profile != null && profile.age > 0 ? ', ${profile.age}' : '');
          final ImageProvider<Object> avatar = (profile != null && profile.imgURL.isNotEmpty)
              ? (NetworkImage(profile.imgURL) as ImageProvider<Object>)
              : (const AssetImage('assets/images/couple.png') as ImageProvider<Object>);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.pink.shade100,
                      child: CircleAvatar(
                        radius: 28.r,
                        backgroundImage: avatar,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameAge,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            EnumLocale.eventParticipationDistance.name.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${EnumLocale.derniereConnexion.name.tr}: ${'il y a'.tr} 2h',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            EnumLocale.chercheRelationSerieuse.name.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Event Organizer Statistics
                Text(
                  '${EnumLocale.eventOrganizedPrefix.name.tr} 20',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${EnumLocale.eventToDoPrefix.name.tr} ${widget.event.status == EventStatus.DUO ? EnumLocale.duoText.name.tr : EnumLocale.groupText.name.tr}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Event Details Section
                Center(
                  child: Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EnumLocale.eventDateLabel.name.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _formatDate(widget.event.date),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EnumLocale.eventPlaceLabel.name.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.event.location,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12.h),
                
                Text(
                  '${EnumLocale.eventFeesLabel.name.tr} ${widget.event.costCovered ? EnumLocale.eventCostCoveredYes.name.tr : EnumLocale.eventCostCoveredNo.name.tr}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                
                if (widget.event.maxParticipants != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    '${EnumLocale.eventParticipantsCountLabel.name.tr} ${widget.event.maxParticipants}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
                
                SizedBox(height: 32.h),
                
                // Participation Request Section
                Text(
                  EnumLocale.eventParticipationParticipationRequest.name.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: _participationMessageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: EnumLocale.eventParticipationMessageHint.name.tr,
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12.w),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                
                SizedBox(height: 40.h),
                
                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xFF6564C0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          EnumLocale.eventParticipationBack.name.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6564C0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitParticipation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6564C0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                EnumLocale.eventParticipationValidate.name.tr,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submitParticipation() async {
    final message = _participationMessageController.text.trim();
    
    // Validate message is not empty (mandatory field)
    if (message.isEmpty) {
      Get.snackbar(
        EnumLocale.eventParticipationError.name.tr,
        EnumLocale.eventParticipationErrorMessage.name.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get current user's profile information
      final profileRepo = ProfileRepository();
      final currentUserProfile = await profileRepo.fetchUserDataById(currentUser.uid);
      
      String requesterName = '';
      String? requesterPhotoUrl;
      
      if (currentUserProfile != null) {
        final profileData = currentUserProfile.toMap();
        final name = profileData['name']?.toString().trim() ?? '';
        final surname = profileData['surname']?.toString().trim() ?? '';
        requesterName = '$name $surname'.trim();
        if (requesterName.isEmpty) {
          requesterName = profileData['pseudo']?.toString().trim() ?? '';
        }
        requesterPhotoUrl = profileData['imgURL']?.toString();
      }

      // Submit the participation request
      await _eventRequestRepository.submitParticipationRequest(
        eventId: widget.event.id,
        eventCreatorId: widget.event.creatorId,
        message: message,
        eventTitle: widget.event.title,
        requesterName: requesterName.isNotEmpty ? requesterName : null,
        requesterPhotoUrl: requesterPhotoUrl,
      );

      setState(() {
        _isSubmitting = false;
      });

      Get.snackbar(
        EnumLocale.eventParticipationSuccess.name.tr,
        EnumLocale.eventParticipationSuccessMessage.name.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      String errorMessage = EnumLocale.eventParticipationErrorMessage.name.tr;
      if (e.toString().contains('already have a pending request')) {
        errorMessage = 'You already have a pending request for this event';
      } else if (e.toString().contains('not authenticated')) {
        errorMessage = 'Please log in to submit your request';
      }

      Get.snackbar(
        EnumLocale.eventParticipationError.name.tr,
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _formatDate(DateTime d) => '${_pad(d.day)}/${_pad(d.month)}/${d.year}';
}
