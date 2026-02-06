import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final StoriesRepository _storiesRepository = StoriesRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Text field will be empty by default
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        EnumLocale.errorWithMessage.name.tr,
        EnumLocale.impossibleSelectionnerImage.name.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _createStory() async {
    if (_selectedImage == null) {
      Get.snackbar(
        EnumLocale.errorWithMessage.name.tr,
        EnumLocale.erreurImage.name.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_textController.text.trim().isEmpty) {
      Get.snackbar(
        EnumLocale.errorWithMessage.name.tr,
        EnumLocale.erreurTexte.name.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if user already has a story created within last 24 hours
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        final storyQuery = await _storiesRepository.firestore
            .collection('stories')
            .where('uid', isEqualTo: currentUserId)
            .get();

        if (storyQuery.docs.isNotEmpty) {
          // Check if any story was created within last 24 hours
          final now = DateTime.now();
          final twentyFourHoursAgo = now.subtract(Duration(hours: 24));
          
          for (var doc in storyQuery.docs) {
            final data = doc.data();
            final createdDate = data['createdDate'];
            
            if (createdDate != null) {
              DateTime storyDate;
              if (createdDate is Timestamp) {
                storyDate = createdDate.toDate();
              } else if (createdDate is int) {
                storyDate = DateTime.fromMillisecondsSinceEpoch(createdDate);
              } else {
                continue; // Skip if we can't parse the date
              }
              
              if (storyDate.isAfter(twentyFourHoursAgo)) {
                Get.snackbar(
                  EnumLocale.errorWithMessage.name.tr,
                  EnumLocale.story24Heures.name.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                );
                return;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error checking existing stories: $e');
      // Continue with story creation if there's an error checking
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _storiesRepository.createStory(
        _selectedImage!,
        _textController.text.trim(),
      );
      
      // Navigate back to previous page
      Get.back();
    } catch (e) {
      Get.snackbar(
        EnumLocale.errorWithMessage.name.tr,
        '${EnumLocale.erreurCreationStory.name.tr} ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          EnumLocale.creerStory.name.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto-SemiBold',
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Section
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Color(0xFFF7BD8E),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30.r,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            EnumLocale.chargerImage.name.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFFF7BD8E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            
            SizedBox(height: 16.h),
            
            // Text Input Section
            Text(
              EnumLocale.taperTexte.name.tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            
            SizedBox(height: 6.h),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: EnumLocale.decrireStory.name.tr,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF7BD8E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        EnumLocale.creerStoryButton.name.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Back Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black,
                  side: BorderSide(color: Color(0xFFF7BD8E)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  EnumLocale.retour.name.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 