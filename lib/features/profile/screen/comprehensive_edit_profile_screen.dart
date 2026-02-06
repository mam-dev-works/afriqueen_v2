import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/services/comprehensive_edit_profile_service.dart';
import 'package:afriqueen/features/activity/model/user_profile_model.dart';
import 'package:afriqueen/features/profile/widget/image_crop_preview_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ComprehensiveEditProfileScreen extends StatefulWidget {
  const ComprehensiveEditProfileScreen({super.key});

  @override
  State<ComprehensiveEditProfileScreen> createState() => _ComprehensiveEditProfileScreenState();
}

class _ComprehensiveEditProfileScreenState extends State<ComprehensiveEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _service = ComprehensiveEditProfileService();
  
  // Loading and saving states
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfileModel? _userProfile;
  
  // Text controllers for all fields
  final _fullNameController = TextEditingController();
  final _sexualOrientationController = TextEditingController();
  final _maritalStatusController = TextEditingController();
  final _secondaryInterestsController = TextEditingController();
  final _heightController = TextEditingController();
  final _silhouetteController = TextEditingController();
  final _religionController = TextEditingController();
  final _childrenController = TextEditingController();
  final _havePetsController = TextEditingController();
  final _spokenLanguagesController = TextEditingController();
  final _educationLevelController = TextEditingController();
  final _professionController = TextEditingController();
  final _incomeLevelController = TextEditingController();
  final _doYouDrinkController = TextEditingController();
  final _doYouSmokeController = TextEditingController();
  final _doYouSnoreController = TextEditingController();
  final _yourHobbiesController = TextEditingController();
  final _describePersonalityController = TextEditingController();
  final _whatLookingForController = TextEditingController();
  final _whatNotWantController = TextEditingController();

  // Selected items for multi-select fields
  List<String> _selectedPassions = [];
  List<String> _selectedQualities = [];
  List<String> _selectedFlaws = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _sexualOrientationController.dispose();
    _maritalStatusController.dispose();
    _secondaryInterestsController.dispose();
    _heightController.dispose();
    _silhouetteController.dispose();
    _religionController.dispose();
    _childrenController.dispose();
    _havePetsController.dispose();
    _spokenLanguagesController.dispose();
    _educationLevelController.dispose();
    _professionController.dispose();
    _incomeLevelController.dispose();
    _doYouDrinkController.dispose();
    _doYouSmokeController.dispose();
    _doYouSnoreController.dispose();
    _yourHobbiesController.dispose();
    _describePersonalityController.dispose();
    _whatLookingForController.dispose();
    _whatNotWantController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = await _service.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _populateFields(profile);
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(UserProfileModel profile) {
    // Basic Information
    _fullNameController.text = profile.name.isNotEmpty ? profile.name : '';
    _sexualOrientationController.text = profile.orientation ?? '';
    _maritalStatusController.text = profile.relationshipStatus ?? '';
    _secondaryInterestsController.text = profile.secondaryInterests?.join(', ') ?? '';
    
    // Physical Information
    _heightController.text = profile.height?.toString() ?? '';
    _silhouetteController.text = _getSilhouetteText(profile.silhouette);
    _religionController.text = profile.religions?.isNotEmpty == true ? profile.religions!.first : '';
    
    // Personal Information
    _childrenController.text = ComprehensiveEditProfileService.intToYesNo(profile.hasChildren) ?? 'Non';
    _havePetsController.text = ComprehensiveEditProfileService.intToYesNo(profile.hasAnimals) ?? 'Non';
    _spokenLanguagesController.text = profile.languages?.join(', ') ?? '';
    _educationLevelController.text = profile.educationLevels?.isNotEmpty == true ? profile.educationLevels!.first : '';
    _professionController.text = profile.occupation ?? '';
    _incomeLevelController.text = profile.incomeLevel ?? '';
    
    // Lifestyle Questions
    _doYouDrinkController.text = ComprehensiveEditProfileService.intToYesNo(profile.alcohol) ?? 'Non';
    _doYouSmokeController.text = ComprehensiveEditProfileService.intToYesNo(profile.smoking) ?? 'Non';
    _doYouSnoreController.text = ComprehensiveEditProfileService.intToYesNo(profile.snoring) ?? 'Non';
    _yourHobbiesController.text = profile.hobbies?.join(', ') ?? '';
    
    // Description Fields
    _describePersonalityController.text = profile.description ?? '';
    _whatLookingForController.text = profile.whatLookingFor ?? '';
    _whatNotWantController.text = profile.whatNotWant ?? '';

    // Multi-select fields
    _selectedPassions = profile.passions ?? [];
    _selectedQualities = profile.qualities ?? [];
    _selectedFlaws = profile.flaws ?? [];
  }

  String _getSilhouetteText(int? silhouette) {
    if (silhouette == null) return '';
    final options = ComprehensiveEditProfileService.getSilhouetteOptions();
    if (silhouette >= 0 && silhouette < options.length) {
      return options[silhouette];
    }
    return '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final success = await _service.updateUserProfile(
        name: _fullNameController.text.trim(),
        orientation: _sexualOrientationController.text.trim(),
        relationshipStatus: _maritalStatusController.text.trim(),
        secondaryInterests: _secondaryInterestsController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        passions: _selectedPassions,
        height: ComprehensiveEditProfileService.stringToInt(_heightController.text),
        silhouette: _getSilhouetteIndex(_silhouetteController.text),
        religions: _religionController.text.trim().isNotEmpty ? [_religionController.text.trim()] : null,
        qualities: _selectedQualities,
        flaws: _selectedFlaws,
        hasChildren: ComprehensiveEditProfileService.yesNoToInt(_childrenController.text),
        hasAnimals: ComprehensiveEditProfileService.yesNoToInt(_havePetsController.text),
        languages: _spokenLanguagesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        educationLevels: _educationLevelController.text.trim().isNotEmpty ? [_educationLevelController.text.trim()] : null,
        occupation: _professionController.text.trim(),
        incomeLevel: _incomeLevelController.text.trim(),
        alcohol: ComprehensiveEditProfileService.yesNoToInt(_doYouDrinkController.text),
        smoking: ComprehensiveEditProfileService.yesNoToInt(_doYouSmokeController.text),
        snoring: ComprehensiveEditProfileService.yesNoToInt(_doYouSnoreController.text),
        hobbies: _yourHobbiesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        description: _describePersonalityController.text.trim(),
        whatLookingFor: _whatLookingForController.text.trim(),
        whatNotWant: _whatNotWantController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          EnumLocale.saveProfile.name.tr,
          EnumLocale.profileSavedSuccessfully.name.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          EnumLocale.errorSavingProfile.name.tr,
          EnumLocale.errorSavingProfile.name.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        EnumLocale.errorSavingProfile.name.tr,
        EnumLocale.errorSavingProfile.name.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  int? _getSilhouetteIndex(String text) {
    final options = ComprehensiveEditProfileService.getSilhouetteOptions();
    return options.indexOf(text);
  }

  Future<void> _selectPhoto(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 100,
      );

      if (image != null) {
        // Show cropping and preview screen
        final File originalFile = File(image.path);
        final File? croppedFile = await Get.to<File>(
          () => ImageCropPreviewScreen(
            imageFile: originalFile,
            photoIndex: index,
          ),
        );

        if (croppedFile != null) {
          // Show loading indicator
          Get.dialog(
            Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Uploading photo...',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          // Upload and save URL
          final String? url = await _service.uploadPhoto(croppedFile, index: index);
          Get.back(); // Close loading dialog

          if (url != null) {
            final saved = await _service.savePhotoUrlAtIndex(url, index: index);
            if (saved) {
              // Refresh local state
              await _loadUserProfile();
              Get.snackbar(
                EnumLocale.submit.name.tr,
                EnumLocale.profileSavedSuccessfully.name.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar(
                'Error',
                EnumLocale.errorSavingProfile.name.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              'Error',
              'Failed to upload photo',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    } catch (e) {
      print('Error selecting photo: $e');
      Get.snackbar(
        'Error',
        'Failed to select photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          EnumLocale.editProfileTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(
                Icons.save,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    EnumLocale.loadingProfile.name.tr,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Profile Photos Section
              _buildProfilePhotosSection(),
              SizedBox(height: 24.h),
              
              // Basic Information
              _buildInputField(
                label: EnumLocale.fullName.name.tr,
                controller: _fullNameController,
                isRequired: true,
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.sexualOrientation.name.tr,
                controller: _sexualOrientationController,
                options: ComprehensiveEditProfileService.getOrientationOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.maritalStatus.name.tr,
                controller: _maritalStatusController,
                options: ComprehensiveEditProfileService.getRelationshipStatusOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.secondaryInterests.name.tr,
                controller: _secondaryInterestsController,
              ),
              SizedBox(height: 24.h),
              
              // Passion Section
              _buildPassionSection(),
              SizedBox(height: 24.h),
              
              // Physical Information
              _buildInputField(
                label: EnumLocale.height.name.tr,
                controller: _heightController,
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.silhouette.name.tr,
                controller: _silhouetteController,
                options: ComprehensiveEditProfileService.getSilhouetteOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.religion.name.tr,
                controller: _religionController,
                options: ComprehensiveEditProfileService.getReligionOptions(),
              ),
              SizedBox(height: 24.h),
              
              // Qualities Section
              _buildQualitiesSection(),
              SizedBox(height: 24.h),
              
              // Flaws Section
              _buildFlawsSection(),
              SizedBox(height: 24.h),
              
              // Personal Information
              _buildInputField(
                label: EnumLocale.children.name.tr,
                controller: _childrenController,
                options: ComprehensiveEditProfileService.getChildrenOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.havePets.name.tr,
                controller: _havePetsController,
                options: ComprehensiveEditProfileService.getYesNoOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.spokenLanguages.name.tr,
                controller: _spokenLanguagesController,
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.educationLevel.name.tr,
                controller: _educationLevelController,
                options: ComprehensiveEditProfileService.getEducationLevelOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.profession.name.tr,
                controller: _professionController,
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.incomeLevel.name.tr,
                controller: _incomeLevelController,
                options: ComprehensiveEditProfileService.getIncomeLevelOptions(),
              ),
              SizedBox(height: 24.h),
              
              // Lifestyle Questions
              _buildInputField(
                label: EnumLocale.doYouDrink.name.tr,
                controller: _doYouDrinkController,
                options: ComprehensiveEditProfileService.getYesNoOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.doYouSmoke.name.tr,
                controller: _doYouSmokeController,
                options: ComprehensiveEditProfileService.getYesNoOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.doYouSnore.name.tr,
                controller: _doYouSnoreController,
                options: ComprehensiveEditProfileService.getYesNoOptions(),
              ),
              SizedBox(height: 16.h),
              
              _buildInputField(
                label: EnumLocale.yourHobbies.name.tr,
                controller: _yourHobbiesController,
              ),
              SizedBox(height: 24.h),
              
              // Description Fields
              _buildTextAreaField(
                label: EnumLocale.describePersonality.name.tr,
                controller: _describePersonalityController,
                hintText: 'Ma personne ...',
              ),
              SizedBox(height: 16.h),
              
              _buildTextAreaField(
                label: EnumLocale.whatLookingFor.name.tr,
                controller: _whatLookingForController,
                hintText: 'Je recherche une ....',
              ),
              SizedBox(height: 16.h),
              
              _buildTextAreaField(
                label: EnumLocale.whatNotWant.name.tr,
                controller: _whatNotWantController,
                hintText: 'Je ....',
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotosSection() {
    final photos = _userProfile?.photos ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Main photo
            GestureDetector(
              onTap: () => _selectPhoto(0),
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.grey[200],
                  image: photos.isNotEmpty 
                    ? DecorationImage(
                        image: NetworkImage(photos.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: photos.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 40.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12.w),
            // Additional photos
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _selectPhoto(1),
                        child: _buildPhotoSlot(photoUrl: photos.length > 1 ? photos[1] : null),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _selectPhoto(2),
                        child: _buildPhotoSlot(photoUrl: photos.length > 2 ? photos[2] : null),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _selectPhoto(3),
                        child: _buildPhotoSlot(photoUrl: photos.length > 3 ? photos[3] : null),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _selectPhoto(4),
                        child: _buildPhotoSlot(isEmpty: photos.length <= 4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSlot({bool isEmpty = false, String? photoUrl}) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: isEmpty ? Colors.grey[100] : Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!),
        image: photoUrl != null 
          ? DecorationImage(
              image: NetworkImage(photoUrl),
              fit: BoxFit.cover,
            )
          : null,
      ),
      child: isEmpty
          ? Center(
              child: Text(
                'NO PHOTO',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    List<String>? options,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        if (options != null)
          GestureDetector(
            onTap: () => _showOptionsDialog(label, controller, options),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      child: Text(
                        controller.text.isEmpty ? '${EnumLocale.selectOption.name.tr} $label' : controller.text,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: controller.text.isEmpty ? Colors.grey[400] : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          )
        else
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
              ),
              validator: isRequired ? (value) {
                if (value == null || value.isEmpty) {
                  return EnumLocale.requiredText.name.tr;
                }
                return null;
              } : null,
            ),
          ),
      ],
    );
  }

  void _showOptionsDialog(String title, TextEditingController controller, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${EnumLocale.selectOption.name.tr} $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    controller.text = option;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMultiSelectDialog(
    String title,
    List<String> currentSelection,
    List<String> allOptions,
    Function(List<String>) onSelectionChanged,
  ) {
    List<String> tempSelection = List.from(currentSelection);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${EnumLocale.selectMultipleOptions.name.tr} $title'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400.h,
            child: ListView.builder(
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final option = allOptions[index];
                final isSelected = tempSelection.contains(option);
                
                return CheckboxListTile(
                  title: Text(option),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelection.add(option);
                      } else {
                        tempSelection.remove(option);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(EnumLocale.cancel.name.tr),
            ),
            TextButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                Navigator.pop(context);
              },
              child: Text(EnumLocale.done.name.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              EnumLocale.passion.name.tr,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => _showMultiSelectDialog(
                'Passions',
                _selectedPassions,
                ComprehensiveEditProfileService.getPassionOptions(),
                (selected) => setState(() => _selectedPassions = selected),
              ),
              child: Text(
                EnumLocale.modify.name.tr,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _selectedPassions.map((passion) => _buildTag(passion)).toList(),
        ),
      ],
    );
  }

  Widget _buildQualitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              EnumLocale.myQualities.name.tr,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => _showMultiSelectDialog(
                'Qualities',
                _selectedQualities,
                ComprehensiveEditProfileService.getQualityOptions(),
                (selected) => setState(() => _selectedQualities = selected),
              ),
              child: Text(
                EnumLocale.modify.name.tr,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _selectedQualities.map((quality) => _buildTag(quality)).toList(),
        ),
      ],
    );
  }

  Widget _buildFlawsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              EnumLocale.myFlaws.name.tr,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () => _showMultiSelectDialog(
                'Flaws',
                _selectedFlaws,
                ComprehensiveEditProfileService.getFlawOptions(),
                (selected) => setState(() => _selectedFlaws = selected),
              ),
              child: Text(
                EnumLocale.modify.name.tr,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _selectedFlaws.map((flaw) => _buildTag(flaw)).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Color(0xFF8B4513), // Brown color for tags
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
