import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/services/storage/get_storage.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'fr'; // Default to French
  List<Map<String, String>> _languages = [];
  List<Map<String, String>> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _initializeLanguages();
    _getCurrentLanguage();
  }

  void _initializeLanguages() {
    _languages = [
      {'name': EnumLocale.languageFrench.name.tr, 'code': 'fr'},
      {'name': EnumLocale.languageEnglish.name.tr, 'code': 'en'},
    ];
    _filteredLanguages = List.from(_languages);
  }

  void _getCurrentLanguage() {
    final currentLocale = Get.locale;
    if (currentLocale != null) {
      _selectedLanguage = currentLocale.languageCode;
    }
  }

  void _filterLanguages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLanguages = List.from(_languages);
      } else {
        _filteredLanguages = _languages
            .where((lang) => lang['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectLanguage(String code) {
    setState(() {
      _selectedLanguage = code;
    });
  }

  void _validateSelection() {
    Get.updateLocale(Locale(_selectedLanguage));
    AppGetStorage().setLanguageCode(_selectedLanguage);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primaryColor,
            size: 20.r,
          ),
        ),
        title: Text(
          EnumLocale.languageSelectionTitle.name.tr,
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              EnumLocale.languageSelectionSubtitle.name.tr,
              style: TextStyle(
                color: AppColors.black.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterLanguages,
                decoration: InputDecoration(
                  hintText: EnumLocale.languageSearchHint.name.tr,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20.r,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Language list
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: _filteredLanguages.length,
                itemBuilder: (context, index) {
                  final language = _filteredLanguages[index];
                  final isSelected = language['code'] == _selectedLanguage;
                  
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: isSelected 
                          ? Border.all(color: AppColors.primaryColor, width: 1.5)
                          : null,
                    ),
                    child: ListTile(
                      title: Text(
                        language['name']!,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryColor : AppColors.black,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 16.sp,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                              size: 20.r,
                            )
                          : null,
                      onTap: () => _selectLanguage(language['code']!),
                    ),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          // Bottom buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                // Back button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.primaryColor),
                    ),
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        EnumLocale.languageBackButton.name.tr,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: 16.w),
                
                // Validate button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFF7BD8E),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextButton(
                      onPressed: _validateSelection,
                      child: Text(
                        EnumLocale.languageValidateButton.name.tr,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
