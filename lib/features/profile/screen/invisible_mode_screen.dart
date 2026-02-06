import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/widgets/invisible_mode_premium_dialog.dart';
import 'package:afriqueen/services/premium_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class InvisibleModeScreen extends StatefulWidget {
  const InvisibleModeScreen({super.key});

  @override
  State<InvisibleModeScreen> createState() => _InvisibleModeScreenState();
}

class _InvisibleModeScreenState extends State<InvisibleModeScreen> {
  bool _isInvisibleMode = false;
  bool _isLoading = true;
  bool _isPremiumOrElite = false;
  final PremiumService _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _loadInvisibleModeStatus();
    _checkPremiumOrEliteStatus();
  }

  Future<void> _checkPremiumOrEliteStatus() async {
    try {
      final isPremiumOrElite = await _premiumService.isUserPremiumOrElite();
      setState(() {
        _isPremiumOrElite = isPremiumOrElite;
      });
    } catch (e) {
      print('Error checking premium/elite status: $e');
    }
  }

  Future<void> _loadInvisibleModeStatus() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        setState(() {
          _isInvisibleMode = userData['isInvisibleMode'] as bool? ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading invisible mode status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInvisibleMode() async {
    try {
      // Check if user is Premium or Elite
      if (!_isPremiumOrElite) {
        // Show premium required dialog
        InvisibleModePremiumDialog.show(context);
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('id', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final newValue = !_isInvisibleMode;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(userQuery.docs.first.id)
            .update({'isInvisibleMode': newValue});

        setState(() {
          _isInvisibleMode = newValue;
        });
      }
    } catch (e) {
      print('Error toggling invisible mode: $e');
      Get.snackbar(
        EnumLocale.defaultError.name.tr,
        EnumLocale.invisibleModeErrorUpdate.name.tr,
        snackPosition: SnackPosition.BOTTOM,
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
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
          ),
        ),
        title: Text(
          EnumLocale.menuInvisibleMode.name.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFF7BD8E),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description text
                  Text(
                    EnumLocale.invisibleModeDescription.name.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  
                  // Status indicator
                  Center(
                    child: Text(
                      _isInvisibleMode
                          ? EnumLocale.invisibleModeActivated.name.tr
                          : EnumLocale.invisibleModeDeactivated.name.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: _isInvisibleMode
                            ? Colors.green
                            : const Color(0xFFF7BD8E),
                      ),
                    ),
                  ),
                  SizedBox(height: 60.h),
                  
                  // Action buttons
                  Row(
                    children: [
                      // Back button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                EnumLocale.retour.name.tr,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      
                      // Activate/Deactivate button
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleInvisibleMode,
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7BD8E),
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Center(
                              child: Text(
                                _isInvisibleMode
                                    ? EnumLocale.invisibleModeDeactivate.name.tr
                                    : EnumLocale.invisibleModeActivate.name.tr,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

