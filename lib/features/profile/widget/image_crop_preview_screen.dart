import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class ImageCropPreviewScreen extends StatefulWidget {
  final File imageFile;
  final int photoIndex;

  const ImageCropPreviewScreen({
    super.key,
    required this.imageFile,
    required this.photoIndex,
  });

  @override
  State<ImageCropPreviewScreen> createState() => _ImageCropPreviewScreenState();
}

class _ImageCropPreviewScreenState extends State<ImageCropPreviewScreen> {
  File? _croppedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cropImage();
  }

  Future<void> _cropImage() async {
    setState(() => _isLoading = true);

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: EnumLocale.cropImage.name.tr,
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppColors.primaryColor,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white.withOpacity(0.5),
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            statusBarColor: AppColors.primaryColor,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: EnumLocale.cropImage.name.tr,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
            resetAspectRatioEnabled: false,
            aspectRatioLockEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
            doneButtonTitle: EnumLocale.done.name.tr,
            cancelButtonTitle: EnumLocale.cancel.name.tr,
            aspectRatioPickerButtonHidden: false,
          ),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
      );

      if (croppedFile != null) {
        setState(() {
          _croppedFile = File(croppedFile.path);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        Get.back(result: null);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error cropping image: $e');
      Get.snackbar(
        EnumLocale.errorPrefix.name.tr,
        'Failed to crop image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back(result: null);
    }
  }

  void _reCrop() {
    _cropImage();
  }

  void _confirmCrop() {
    if (_croppedFile != null) {
      Get.back(result: _croppedFile);
    } else {
      Get.snackbar(
        EnumLocale.errorPrefix.name.tr,
        'No cropped image available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70.h,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w, top: 12.h),
          child: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 28.sp,
            ),
            onPressed: () => Get.back(result: null),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Text(
            EnumLocale.previewImage.name.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryColor,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      EnumLocale.processingImage.name.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              )
            : _croppedFile == null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        EnumLocale.noImageAvailable.name.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: 70.h), // Space for app bar
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          child: Center(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: Image.file(
                                _croppedFile!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 15,
                              offset: Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _reCrop,
                                  icon: Icon(
                                    Icons.crop,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                  label: Text(
                                    EnumLocale.reCrop.name.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                      horizontal: 18.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _confirmCrop,
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 22.sp,
                                  ),
                                  label: Text(
                                    EnumLocale.confirm.name.tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                      horizontal: 18.w,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
