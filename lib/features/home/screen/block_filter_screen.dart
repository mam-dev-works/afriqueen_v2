import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/features/home/screen/marital_status_screen.dart';
import 'package:afriqueen/features/home/screen/main_interest_screen.dart';
import 'package:afriqueen/features/visibility/repository/visibility_repository.dart';

class BlockFilterScreen extends StatefulWidget {
  const BlockFilterScreen({super.key});

  @override
  State<BlockFilterScreen> createState() => _BlockFilterScreenState();
}

class _BlockFilterScreenState extends State<BlockFilterScreen> {
  final VisibilityRepository _visibilityRepository = VisibilityRepository();
  // Profile type
  List<String> _selectedProfileTypes = ['Élite'];
  
  // Sex
  List<String> _selectedSexes = ['Femme'];
  
  // Sexual orientation
  List<String> _selectedOrientations = ['Hétéro'];
  
  // Age range
  RangeValues _ageRange = const RangeValues(18, 99);
  
  // Distance range
  RangeValues _distanceRange = const RangeValues(0, 500);
  
  // Certified profiles only
  bool _certifiedOnly = false;
  
  // Marital status
  List<String> _selectedMaritalStatuses = [];
  
  // Main interest
  List<String> _selectedMainInterests = [];
  
  // Age none option
  bool _ageNone = false;
  
  // Distance none option
  bool _distanceNone = false;

  @override
  void initState() {
    super.initState();
    _loadExistingInvisibility();
  }

  Future<void> _loadExistingInvisibility() async {
    try {
      final prefs = await _visibilityRepository.fetchInvisibilityPreferences();
      setState(() {
        _selectedProfileTypes = List<String>.from(prefs['invisibleToProfileTypes'] ?? []);
        _selectedSexes = List<String>.from(prefs['invisibleToSexes'] ?? []);
        _selectedOrientations = List<String>.from(prefs['invisibleToOrientations'] ?? []);
      });
    } catch (e) {
      // ignore errors silently
    }
  }

  Future<void> _saveInvisibility() async {
    try {
      await _visibilityRepository.updateInvisibilityPreferences(
        invisibleToProfileTypes: _selectedProfileTypes,
        invisibleToSexes: _selectedSexes,
        invisibleToOrientations: _selectedOrientations,
      );
      Get.snackbar('Succès', 'Préférences enregistrées');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de l\'enregistrement');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: 24.r,
          ),
        ),
        title: Text(
          'Liste filtre/Bloquer/Base',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto-SemiBold',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Reset button at top
          _buildResetButton(),
          
          // Main filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // Profile section with title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: Color(0xFF181A1F),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildFilterSection('', _buildProfileTypeFilter()),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Sex section with title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sexe',
                        style: TextStyle(
                          color: Color(0xFF181A1F),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildFilterSection('', _buildSexFilter()),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Orientation section with title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orientation sexuel',
                        style: TextStyle(
                          color: Color(0xFF181A1F),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildFilterSection('', _buildOrientationFilter()),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Age section without title (title is inside)
                  _buildFilterSection('', _buildAgeFilter()),
                  SizedBox(height: 12.h),
                  // Distance section without title (title is inside)
                  _buildFilterSection('', _buildDistanceFilter()),
                  SizedBox(height: 12.h),
                  // Marital status section
                  _buildFilterSection(
                    '',
                    _buildMaritalStatusFilter(),
                  ),
                  SizedBox(height: 12.h),
                  // Main interest section
                  _buildFilterSection(
                    '',
                    _buildMainInterestFilter(),
                  ),
                  SizedBox(height: 12.h),
                  // Certified profile section without title (title is inside)
                  _buildFilterSection(
                    '',
                    _buildCertifiedFilter(),
                  ),
                  SizedBox(height: 32.h), // Space before apply button
                  
                  // Apply button inside scroll view
                  _buildApplyButton(),
                  
                  SizedBox(height: 20.h), // Space at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedProfileTypes = ['Élite'];
              _selectedSexes = ['Femme'];
              _selectedOrientations = ['Hétéro'];
              _ageRange = const RangeValues(18, 99);
              _distanceRange = const RangeValues(0, 500);
              _certifiedOnly = false;
              _selectedMaritalStatuses = [];
              _selectedMainInterests = [];
              _ageNone = false;
              _distanceNone = false;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: Colors.pink.shade200, width: 1),
            ),
            child: Text(
              'Supprimer tous les filtres',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }

  Widget _buildProfileTypeFilter() {
    return Row(
      children: [
        _buildOvalButton('Élite', _selectedProfileTypes.contains('Élite'), () {
          setState(() {
            if (_selectedProfileTypes.contains('Élite')) {
              _selectedProfileTypes.remove('Élite');
            } else {
              _selectedProfileTypes.add('Élite');
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton('Classique', _selectedProfileTypes.contains('Classique'), () {
          setState(() {
            if (_selectedProfileTypes.contains('Classique')) {
              _selectedProfileTypes.remove('Classique');
            } else {
              _selectedProfileTypes.add('Classique');
            }
          });
        }),
      ],
    );
  }

  Widget _buildSexFilter() {
    return Row(
      children: [
        _buildOvalButton('Homme', _selectedSexes.contains('Homme'), () {
          setState(() {
            if (_selectedSexes.contains('Homme')) {
              _selectedSexes.remove('Homme');
            } else {
              _selectedSexes.add('Homme');
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton('Femme', _selectedSexes.contains('Femme'), () {
          setState(() {
            if (_selectedSexes.contains('Femme')) {
              _selectedSexes.remove('Femme');
            } else {
              _selectedSexes.add('Femme');
            }
          });
        }),
      ],
    );
  }

  Widget _buildOrientationFilter() {
    return Row(
      children: [
        _buildOvalButton('Hétéro', _selectedOrientations.contains('Hétéro'), () {
          setState(() {
            if (_selectedOrientations.contains('Hétéro')) {
              _selectedOrientations.remove('Hétéro');
            } else {
              _selectedOrientations.add('Hétéro');
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton('Homo', _selectedOrientations.contains('Homo'), () {
          setState(() {
            if (_selectedOrientations.contains('Homo')) {
              _selectedOrientations.remove('Homo');
            } else {
              _selectedOrientations.add('Homo');
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton('Bi', _selectedOrientations.contains('Bi'), () {
          setState(() {
            if (_selectedOrientations.contains('Bi')) {
              _selectedOrientations.remove('Bi');
            } else {
              _selectedOrientations.add('Bi');
            }
          });
        }),
      ],
    );
  }

  Widget _buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                         Text(
               'Âge',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 14.sp,
                 fontWeight: FontWeight.w600,
               ),
             ),
                         Text(
               '${_ageRange.start.round()} à ${_ageRange.end.round()}+',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w500,
               ),
             ),
          ],
        ),
        SizedBox(height: 12.h),
        RangeSlider(
          values: _ageRange,
          min: 18,
          max: 99,
          divisions: 81,
          activeColor: AppColors.red,
          inactiveColor: Colors.grey.shade300,
          onChanged: (RangeValues values) {
            setState(() {
              _ageRange = values;
            });
          },
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Checkbox(
              value: _ageNone,
              onChanged: (value) {
                setState(() {
                  _ageNone = value ?? false;
                });
              },
              activeColor: Color(0xFFF7BD8E),
              side: BorderSide(
                color: Color(0xFFF7BD8E),
                width: 1,
              ),
            ),
            Text(
              'Aucun',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                         Text(
               'Distance de moi en km',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 14.sp,
                 fontWeight: FontWeight.w600,
               ),
             ),
                         Text(
               'De ${_distanceRange.start.round()} à ${_distanceRange.end.round()}+',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w500,
               ),
             ),
          ],
        ),
        SizedBox(height: 12.h),
        RangeSlider(
          values: _distanceRange,
          min: 0,
          max: 500,
          divisions: 50,
          activeColor: AppColors.red,
          inactiveColor: Colors.grey.shade300,
          onChanged: (RangeValues values) {
            setState(() {
              _distanceRange = values;
            });
          },
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Checkbox(
              value: _distanceNone,
              onChanged: (value) {
                setState(() {
                  _distanceNone = value ?? false;
                });
              },
              activeColor: Color(0xFFF7BD8E),
              side: BorderSide(
                color: Color(0xFFF7BD8E),
                width: 1,
              ),
            ),
            Text(
              'Aucun',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaritalStatusFilter() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => MaritalStatusScreen(
          initialSelections: _selectedMaritalStatuses,
        ));
        if (result != null) {
          setState(() {
            _selectedMaritalStatuses = List<String>.from(result);
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Statut matrimonial',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.black,
            size: 16.r,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInterestFilter() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(() => MainInterestScreen(
          initialSelections: _selectedMainInterests,
        ));
        if (result != null) {
          setState(() {
            _selectedMainInterests = List<String>.from(result);
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Intérêt principal',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColors.black,
            size: 16.r,
          ),
        ],
      ),
    );
  }

  Widget _buildCertifiedFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
                 Text(
           'Profil certifié uniquement',
           style: TextStyle(
             color: AppColors.black,
             fontSize: 14.sp,
             fontWeight: FontWeight.w600,
           ),
         ),
        Switch(
          value: _certifiedOnly,
          onChanged: (value) {
            setState(() {
              _certifiedOnly = value;
            });
          },
          activeColor: AppColors.primaryColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildOvalButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF7BD8E) : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF181A1F),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: SizedBox(
          width: 124.w,
          height: 40.h,
          child: ElevatedButton(
            onPressed: () async {
              await _saveInvisibility();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF7BD8E),
              foregroundColor: Color(0xFFFFFFFF),
              padding: EdgeInsets.symmetric(
                vertical: 11.h,
                horizontal: 10.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Appliquer',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                height: 1.0,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 