import 'package:flutter/material.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/interest_fields.dart';
import '../widget/staff_fields.dart';
import '../widget/professional_fields.dart';
import '../widget/physical_fields.dart';
import '../model/edit_profile_model.dart';
import '../repository/edit_profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileRepository _repository = EditProfileRepository();
  final EditProfileModel _model = EditProfileModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _repository.getProfile();
      if (profile != null) {
        setState(() {
          _model.interests = profile.interests;
          _model.age = profile.age;
          _model.spokenLanguages = profile.spokenLanguages;
          _model.religion = profile.religion;
          _model.hasChildren = profile.hasChildren;
          _model.wantChildren = profile.wantChildren;
          _model.character = profile.character;
          _model.occupation = profile.occupation;
          _model.levelOfStudy = profile.levelOfStudy;
          _model.professionalLanguages = profile.professionalLanguages;
          _model.incomeLevel = profile.incomeLevel;
          _model.physicalAge = profile.physicalAge;
          _model.size = profile.size;
          _model.weight = profile.weight;
          _model.silhouette = profile.silhouette;
          _model.ethnicOrigin = profile.ethnicOrigin;
          _model.description = profile.description;
          _model.lookingFor = profile.lookingFor;
          _model.dontWant = profile.dontWant;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      Get.snackbar(
        'Error',
        EnumLocale.loadFailMessage.name.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(EnumLocale.editProfile.name.tr),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await _repository.updateProfile(_model);
                Get.back();
                Get.snackbar(
                  'Success',
                  EnumLocale.updateSuccessMessage.name.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                print('Error updating profile: $e');
                Get.snackbar(
                  'Error',
                  EnumLocale.updateFailMessage.name.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
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
              EnumLocale.loading.name.tr,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      )
          : DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: AppColors.primaryColor,
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: EnumLocale.interests.name.tr),
                  Tab(text: EnumLocale.staff.name.tr),
                  Tab(text: EnumLocale.professional.name.tr),
                  Tab(text: EnumLocale.physical.name.tr),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  InterestFields(model: _model),
                  StaffFields(model: _model),
                  ProfessionalFields(model: _model),
                  PhysicalFields(model: _model),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 