import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_event.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class UnifiedProfileSetupScreen extends StatefulWidget {
  const UnifiedProfileSetupScreen({super.key});

  @override
  State<UnifiedProfileSetupScreen> createState() => _UnifiedProfileSetupScreenState();
}

class _UnifiedProfileSetupScreenState extends State<UnifiedProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDob;
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedCity;

  // Main and secondary interest options
  final List<String> mainInterests = [
    EnumLocale.mainInterestMeetings.name.tr,
    EnumLocale.mainInterestChat.name.tr,
    EnumLocale.mainInterestSeriousStory.name.tr,
    EnumLocale.mainInterestFriendship.name.tr,
    EnumLocale.mainInterestFlirt.name.tr,
    EnumLocale.mainInterestAdventure.name.tr,
  ];
  final List<String> secondaryInterests = [
    EnumLocale.secondaryInterestOutings.name.tr,
    EnumLocale.secondaryInterestChat.name.tr,
    EnumLocale.secondaryInterestSeriousStory.name.tr,
    EnumLocale.secondaryInterestFriendship.name.tr,
    EnumLocale.secondaryInterestFlirt.name.tr,
    EnumLocale.secondaryInterestAdventure.name.tr,
  ];

  // Passions options
  final List<String> allPassions = [
    EnumLocale.passionSport.name.tr,
    EnumLocale.passionVideoGames.name.tr,
    EnumLocale.passionDuoActivities.name.tr,
    EnumLocale.passionCinema.name.tr,
    EnumLocale.passionReading.name.tr,
    EnumLocale.passionPhotography.name.tr,
    EnumLocale.passionActivities.name.tr,
    EnumLocale.passionTravel.name.tr,
    EnumLocale.passionCooking.name.tr,
    EnumLocale.passionOutings.name.tr,
    EnumLocale.passionMusic.name.tr,
    EnumLocale.passionPainting.name.tr,
  ];
  List<String> selectedPassions = [];
  String passionSearch = '';

  // Selection state
  int? selectedMainInterest; // Only one can be selected
  List<int> selectedSecondaryInterests = []; // Only one can be selected now

  // Photo picker state
  final ImagePicker _picker = ImagePicker();
  List<XFile?> _photos = List<XFile?>.filled(6, null);

  Future<void> _pickPhoto(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos[index] = image;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos[index] = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get filteredPassions {
    if (passionSearch.isEmpty) return allPassions;
    return allPassions.where((p) => p.toLowerCase().contains(passionSearch.toLowerCase())).toList();
  }

  Widget buildInterestGridStyled({
    required List<String> options,
    required List<int> selectedIndexes,
    required Function(int) onTap,
    bool singleSelect = false,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 60.w,
      childAspectRatio: 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(options.length, (index) {
        final selected = selectedIndexes.contains(index);
        return GestureDetector(
          onTap: () => onTap(index),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) => onTap(index),
                activeColor: Color(0xFFB85C38),
                checkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: selected ? Color(0xFFB85C38) : Color(0xFF232323),
                  width: 2,
                ),
              ),
              Expanded(
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    height: 1.0,
                    letterSpacing: 0,
                    color: selected ? Color(0xFFB85C38) : Colors.black,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  int _height = 155;
  int _selectedSilhouette = 0;

  // State for ethnic origin and religion selections
  List<int> _selectedEthnicOrigins = [];
  List<int> _selectedReligions = [];

  // State for qualities and flaws selections
  List<int> _selectedQualities = [];
  List<int> _selectedFlaws = [];

  // State for enfants and want enfants selections
  int _selectedEnfants = -1;
  int _selectedWantEnfants = -1;

  // State for animaux selection
  int _selectedAnimaux = -1;

  // State for hobbies selection
  List<int> _selectedHobbies = [];
  final TextEditingController _searchDescriptionController = TextEditingController();
  final TextEditingController _whatYouAreLookingForController = TextEditingController();
  final TextEditingController _whatYouDontWantController = TextEditingController();

  // Helper widget for 2-column checkbox grid
  Widget _buildCheckboxGrid({required List<String> options, required List<int> selected, required Function(int) onChanged}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 4.5,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final isSelected = selected.contains(index);
        return GestureDetector(
          onTap: () => onChanged(index),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onChanged(index),
                activeColor: Color(0xFFB85C38),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                ),
                Flexible(
                  child: Text(
                    options[index],
                    style: TextStyle(
                    fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
          ),
        );
      },
    );
  }

  // Helper widget for outlined button group
  Widget _buildOutlinedButtonGroup({required List<String> options, required int selected, required Function(int) onChanged}) {
    return Column(
      children: List.generate(options.length, (index) {
        final isSelected = selected == index;
        return GestureDetector(
          onTap: () => onChanged(index),
          child: Container(
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? Color(0xFFB085FF) : Color(0xFFE6E6E6),
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              options[index],
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                fontSize: 16.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        );
      }),
    );
  }

  // Language selection state
  final List<String> allLanguages = [
    EnumLocale.languageFrench.name.tr, EnumLocale.languageEnglish.name.tr, EnumLocale.languageSpanish.name.tr, EnumLocale.languageGerman.name.tr, EnumLocale.languageItalian.name.tr, EnumLocale.languagePortuguese.name.tr,
    EnumLocale.languageArabic.name.tr, EnumLocale.languageRussian.name.tr, EnumLocale.languageChinese.name.tr, EnumLocale.languageJapanese.name.tr, EnumLocale.languageTurkish.name.tr, EnumLocale.languageDutch.name.tr,
    EnumLocale.languageHindi.name.tr, EnumLocale.languageBengali.name.tr, EnumLocale.languagePolish.name.tr, EnumLocale.languageRomanian.name.tr, EnumLocale.languageGreek.name.tr, EnumLocale.languageKorean.name.tr,
    EnumLocale.languageVietnamese.name.tr, EnumLocale.languageThai.name.tr, EnumLocale.languageOther.name.tr
  ];
  List<String> selectedLanguages = [];
  String languageSearch = '';

  List<String> get filteredLanguages {
    if (languageSearch.isEmpty) return allLanguages;
    return allLanguages.where((l) => l.toLowerCase().contains(languageSearch.toLowerCase())).toList();
  }

  // State for education level selection
  List<int> _selectedEducationLevels = [];

  // State for alcohol question selection
  int _selectedAlcohol = -1;
  int _selectedSmoking = -1;
  int _selectedSnoring = -1;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProfileBloc, CreateProfileState>(
      listener: (context, state) {
        if (state is Success) {
          // Close loading dialog if open
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Navigate to main screen on success
          Get.offAllNamed('/main');
        } else if (state is Error) {
          // Close loading dialog if open
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.black,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gender, orientation, relationship status
                BlocBuilder<CreateProfileBloc, CreateProfileState>(
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),
                Center(
                  child: SizedBox(
                    width: 203.w,
                    child: Text(
                      EnumLocale.profileGenderTitle.name.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        height: 1.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => context.read<CreateProfileBloc>().add(GenderChanged(gender: EnumLocale.genderMale.name.tr)),
                                child: Container(
                                  width: 120.w,
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    color: state.gender == EnumLocale.genderMale.name.tr ? const Color(0xFFF8F1ED) : Colors.white,
                                    border: Border.all(
                                      color: state.gender == EnumLocale.genderMale.name.tr ? const Color(0xFFB85C38) : const Color(0xFFE0E0E0),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.person, color: state.gender == EnumLocale.genderMale.name.tr ? const Color(0xFFB85C38) : Colors.grey, size: 32),
                                      SizedBox(height: 8.h),
                                      Text(
                                        EnumLocale.genderMale.name.tr,
                                        style: TextStyle(
                                          color: state.gender == EnumLocale.genderMale.name.tr ? const Color(0xFFB85C38) : Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      if (state.gender == EnumLocale.genderMale.name.tr)
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 4, right: 8),
                                            child: Icon(Icons.radio_button_checked, color: const Color(0xFFB85C38), size: 18),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 24.w),
                              GestureDetector(
                                onTap: () => context.read<CreateProfileBloc>().add(GenderChanged(gender: EnumLocale.genderFemale.name.tr)),
                                child: Container(
                                  width: 120.w,
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    color: state.gender == EnumLocale.genderFemale.name.tr ? const Color(0xFFF8F1ED) : Colors.white,
                                    border: Border.all(
                                      color: state.gender == EnumLocale.genderFemale.name.tr ? const Color(0xFFB85C38) : const Color(0xFFE0E0E0),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.person, color: state.gender == EnumLocale.genderFemale.name.tr ? const Color(0xFFB85C38) : Colors.grey, size: 32),
                                      SizedBox(height: 8.h),
                                      Text(
                                        EnumLocale.genderFemale.name.tr,
                                        style: TextStyle(
                                          color: state.gender == EnumLocale.genderFemale.name.tr ? const Color(0xFFB85C38) : Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                      if (state.gender == EnumLocale.genderFemale.name.tr)
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 4, right: 8),
                                            child: Icon(Icons.radio_button_checked, color: const Color(0xFFB85C38), size: 18),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.gender == EnumLocale.genderFemale.name.tr
                                ? EnumLocale.genderFemaleSelectedText.name.tr
                                : state.gender == EnumLocale.genderMale.name.tr
                                    ? EnumLocale.genderMaleSelectedText.name.tr
                                    : '',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              height: 1.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Orientation toggle buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...[
                                EnumLocale.orientationHetero.name.tr,
                                EnumLocale.orientationHomo.name.tr,
                                EnumLocale.orientationBi.name.tr,
                              ].map((opt) {
                                final isSelected = state.orientation == opt;
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: isSelected ? const Color(0xFFB85C38) : Colors.white,
                                      side: BorderSide(color: isSelected ? const Color(0xFFB85C38) : Colors.grey, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                                    ),
                                    onPressed: () => context.read<CreateProfileBloc>().add(OrientationChanged(orientation: opt)),
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          Center(
                            child: Text(
                              EnumLocale.relationshipStatusTitle.name.tr,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 14.h,
                            crossAxisSpacing: 50.w,
                            childAspectRatio: 102 / 24,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              EnumLocale.relationshipSingle.name.tr,
                              EnumLocale.relationshipCouple.name.tr,
                              EnumLocale.relationshipFiance.name.tr,
                              EnumLocale.relationshipMarried.name.tr,
                              EnumLocale.relationshipUnionLibre.name.tr,
                              EnumLocale.relationshipDivorced.name.tr,
                            ].map((opt) {
                              final isSelected = state.relationshipStatus == opt;
                              return GestureDetector(
                                onTap: () => context.read<CreateProfileBloc>().add(RelationshipStatusChanged(status: opt)),
                                child: SizedBox(
                                  width: 102.w,
                                  height: 24.h,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => context.read<CreateProfileBloc>().add(RelationshipStatusChanged(status: opt)),
                                        activeColor: const Color(0xFFB85C38),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Flexible(
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFB85C38) : Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 40.h),
                // Full Name Section
                Center(
                  child: SizedBox(
                    width: 226.w,
                    child: Text(
                      EnumLocale.fullName.name.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp,
                        height: 1.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: EnumLocale.fullName.name.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Color(0xFFB85C38), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 15.sp,
                    color: Colors.black,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return EnumLocale.requiredText.name.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40.h),
                // Main Interest Section
                Center(
                  child: SizedBox(
                    width: 226.w,
                    height: 58.h,
                    child: Text(
                      EnumLocale.profileMainInterestTitle.name.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 24.sp,
                        height: 1.0,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: SizedBox(
                    width: 296.w,
                    height: 48.h,
                    child: Text(
                      EnumLocale.profileMainInterestSubtitle.name.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 28.h),
                SizedBox(
                  width: 108.w,
                  height: 18.h,
                  child: Text(
                    EnumLocale.profileMainInterestLabel.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 1.29, // 18/14
                      letterSpacing: 0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 12.h),
                buildInterestGridStyled(
                  options: mainInterests.map((e) => e.tr).toList(),
                  selectedIndexes: selectedMainInterest != null ? [selectedMainInterest!] : [],
                  onTap: (index) {
                    setState(() {
                      selectedMainInterest = index;
                    });
                  },
                  singleSelect: true,
                ),
                SizedBox(height: 32.h),
                // Secondary Interest Section
                SizedBox(
                  width: 116.w,
                  height: 18.h,
                  child: Text(
                    EnumLocale.profileSecondaryInterestLabel.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      height: 1.29, // 18/14
                      letterSpacing: 0,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 12.h),
                buildInterestGridStyled(
                  options: secondaryInterests.map((e) => e.tr).toList(),
                  selectedIndexes: selectedSecondaryInterests,
                  onTap: (index) {
                    setState(() {
                      selectedSecondaryInterests = [index];
                    });
                  },
                  singleSelect: true,
                ),
                SizedBox(height: 40.h),
                // Passions Section (after Interet Secondaire)
                Center(
                  child: SizedBox(
                    width: 183.w,
                    height: 58.h,
                    child: Center(
                      child: Text(
                        EnumLocale.profilePassionTitle.name.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                          height: 1.21,
                          letterSpacing: 0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    EnumLocale.profilePassionSubtitle.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
                // Search bar
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              passionSearch = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: EnumLocale.profilePassionSearchHint.name.tr,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Selected tags
                if (selectedPassions.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selectedPassions.map((passion) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFB85C38),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Text(passion, style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14.sp)),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedPassions.remove(passion);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: Center(
                    child: Text(
                      EnumLocale.profilePassionMaxSelection.name.tr,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                        color: Color(0xFFB85C38),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Passions grid
                Wrap(
                  spacing: 16.w,
                  runSpacing: 12.h,
                  children: filteredPassions.map((passion) {
                    final isSelected = selectedPassions.contains(passion);
                    final canSelect = selectedPassions.length < 2 || isSelected;
                    return GestureDetector(
                      onTap: canSelect
                          ? () {
                              setState(() {
                                if (isSelected) {
                                  selectedPassions.remove(passion);
                                } else if (selectedPassions.length < 2) {
                                  selectedPassions.add(passion);
                                }
                              });
                            }
                          : null,
                      child: Text(
                        passion,
                        style: TextStyle(
                          color: isSelected ? Color(0xFFB85C38) : Colors.black,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 15.sp,
                          decoration: canSelect ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 40.h),
                // Photo upload section
                Center(
                  child: SizedBox(
                    width: 193.w,
                    height: 58.h,
                    child: Center(
                      child: Text(
                        EnumLocale.profilePhotoTitle.name.tr,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 24.sp,
                          height: 1.21,
                          letterSpacing: 0,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Text(
                    EnumLocale.profilePhotoSubtitle.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
                // Photo grid (3x2)
                Center(
                  child: SizedBox(
                    width: 320.w,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.h,
                        crossAxisSpacing: 8.w,
                        childAspectRatio: 1,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final photo = _photos[index];
                        if (photo != null) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  File(photo.path),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (index == 0) {
                          // Default profile image if not selected
                          return GestureDetector(
                            onTap: () => _pickPhoto(index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.asset(
                                'assets/images/d1f81f8c99fc618126b5d089ef7b57ef4a7a1280.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => _pickPhoto(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFE6E6E6),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Color(0xFFB85C38), size: 32),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    EnumLocale.profilePhotoWarning.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: Color(0xFFB85C38),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40.h),
                // New section: Height and Silhouette
                Center(
                  child: Text(
                    EnumLocale.profileHeightSectionTitle.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8.h),
                Center(
                  child: Text(
                    EnumLocale.profileHeightSectionSubtitle.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Text(
                    EnumLocale.profileHeightSectionSubtitle.name.tr,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  EnumLocale.profileHeightLabel.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_height > 100) _height--;
                              });
                            },
                          ),
                          Text(
                            '$_height cm',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                if (_height < 250) _height++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  EnumLocale.profileSilhouetteLabel.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                // Silhouette grid (2x2)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 1,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedSilhouette == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSilhouette = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Color(0xFFB85C38) : Color(0xFFE6E6E6),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/silhouette${index + 1}.png',
                            width: 140.w,
                            height: 140.w,
                            color: Color(0xFFB85C38).withOpacity(isSelected ? 1.0 : 0.3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 40.h),
                // Ethnic origin section
                Text(
                  EnumLocale.profileEthnicOriginTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileEthnicOriginSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.ethnicAfrican.name.tr, EnumLocale.ethnicArab.name.tr,
                    EnumLocale.ethnicAsian.name.tr, EnumLocale.ethnicEuropean.name.tr,
                    EnumLocale.ethnicLatino.name.tr, EnumLocale.ethnicOther.name.tr,
                  ],
                  selected: _selectedEthnicOrigins,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedEthnicOrigins.contains(index)) {
                        _selectedEthnicOrigins.remove(index);
                      } else {
                        _selectedEthnicOrigins.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // Religion section
                Text(
                  EnumLocale.profileReligionTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileReligionSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.religionCatholic.name.tr, EnumLocale.religionProtestant.name.tr,
                    EnumLocale.religionIslam.name.tr, EnumLocale.religionAtheist.name.tr,
                    EnumLocale.religionLatino.name.tr, EnumLocale.religionOther.name.tr,
                  ],
                  selected: _selectedReligions,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedReligions.contains(index)) {
                        _selectedReligions.remove(index);
                      } else {
                        _selectedReligions.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 40.h),
                // Caractère - Mes qualités
                Text(
                  EnumLocale.profileQualitiesTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileQualitiesSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.qualityAutonomous.name.tr, EnumLocale.qualitySociable.name.tr,
                    EnumLocale.qualityFunny.name.tr, EnumLocale.qualityCreative.name.tr,
                    EnumLocale.qualityListener.name.tr, EnumLocale.qualityOther.name.tr,
                  ],
                  selected: _selectedQualities,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedQualities.contains(index)) {
                        _selectedQualities.remove(index);
                      } else {
                        _selectedQualities.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // Mes défauts
                Text(
                  EnumLocale.profileFlawsTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileFlawsSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.flawPerfectionist.name.tr, EnumLocale.flawImpulsive.name.tr,
                    EnumLocale.flawProcrastination.name.tr, EnumLocale.flawDemanding.name.tr,
                    EnumLocale.flawSensitive.name.tr, EnumLocale.flawOther.name.tr,
                  ],
                  selected: _selectedFlaws,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedFlaws.contains(index)) {
                        _selectedFlaws.remove(index);
                      } else {
                        _selectedFlaws.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 40.h),
                // Enfants section
                Text(
                  EnumLocale.profileChildrenTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileChildrenSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.profileChildrenYes.name.tr, EnumLocale.profileChildrenNo.name.tr, EnumLocale.profileChildrenNoAnswer.name.tr],
                  selected: _selectedEnfants,
                  onChanged: (index) {
                    setState(() {
                      _selectedEnfants = index;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // Voulez-vous des enfants section
                Text(
                  EnumLocale.profileWantChildrenTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.profileChildrenYes.name.tr, EnumLocale.profileChildrenNo.name.tr],
                  selected: _selectedWantEnfants,
                  onChanged: (index) {
                    setState(() {
                      _selectedWantEnfants = index;
                    });
                  },
                ),
                SizedBox(height: 40.h),
                // Avez-vous les animaux?
                Text(
                  EnumLocale.profileAnimalsTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileAnimalsSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.profileChildrenYes.name.tr, EnumLocale.profileChildrenNo.name.tr],
                  selected: _selectedAnimaux,
                  onChanged: (index) {
                    setState(() {
                      _selectedAnimaux = index;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // Quelles langues parles-tu ?
                Text(
                  EnumLocale.profileLanguagesTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.profileLanguagesSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                // Language search bar and selection
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              languageSearch = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Fr', // This can be localized if needed
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Colors.grey),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Filtered language chips (only when searching and not already selected)
                if (languageSearch.isNotEmpty && filteredLanguages.isNotEmpty)
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 8.h,
                    children: filteredLanguages
                        .where((lang) => !selectedLanguages.contains(lang))
                        .map((lang) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedLanguages.add(lang);
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Text(
                                  lang,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                SizedBox(height: 12.h),
                // Only show selected language tags
                if (selectedLanguages.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: selectedLanguages.map((lang) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          color: Color(0xFFB85C38),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Text(lang, style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14.sp)),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedLanguages.remove(lang);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                SizedBox(height: 12.h),
                Text(
                  EnumLocale.profileLanguagesHelper.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32.h),
                // --- Education Level Section ---
                Text(
                  EnumLocale.educationLevelTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.selectEducationLevel.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.educationNone.name.tr,
                    EnumLocale.educationCollege.name.tr,
                    EnumLocale.educationHighSchool.name.tr,
                    EnumLocale.educationBac.name.tr,
                    EnumLocale.educationBac2.name.tr,
                    EnumLocale.educationLicence.name.tr,
                  ],
                  selected: _selectedEducationLevels,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedEducationLevels.contains(index)) {
                        _selectedEducationLevels.remove(index);
                      } else {
                        _selectedEducationLevels.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // --- Alcohol Question Section ---
                Text(
                  EnumLocale.alcoholQuestionTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.alcoholQuestionSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                  selected: _selectedAlcohol,
                  onChanged: (index) {
                    setState(() {
                      _selectedAlcohol = index;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // --- Smoking Question Section ---
                Text(
                  EnumLocale.smokingQuestionTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.smokingQuestionSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                  selected: _selectedSmoking,
                  onChanged: (index) {
                    setState(() {
                      _selectedSmoking = index;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // --- Snoring Question Section ---
                Text(
                  EnumLocale.snoringQuestionTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.snoringQuestionSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOutlinedButtonGroup(
                  options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr, EnumLocale.dontKnow.name.tr],
                  selected: _selectedSnoring,
                  onChanged: (index) {
                    setState(() {
                      _selectedSnoring = index;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // --- Hobbies Section ---
                Text(
                  EnumLocale.hobbiesTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.hobbiesSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildCheckboxGrid(
                  options: [
                    EnumLocale.hobbySport.name.tr,
                    EnumLocale.hobbyMusic.name.tr,
                    EnumLocale.hobbyPodcasts.name.tr,
                    EnumLocale.hobbyPhotography.name.tr,
                    EnumLocale.hobbyOutings.name.tr,
                    EnumLocale.hobbyArts.name.tr,
                  ],
                  selected: _selectedHobbies,
                  onChanged: (index) {
                    setState(() {
                      if (_selectedHobbies.contains(index)) {
                        _selectedHobbies.remove(index);
                      } else {
                        _selectedHobbies.add(index);
                      }
                    });
                  },
                ),
                SizedBox(height: 32.h),
                // --- Search Description Section ---
                Text(
                  EnumLocale.searchDescriptionTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.searchDescriptionSubtitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _searchDescriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: EnumLocale.searchDescriptionHint.name.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 15.sp,
                      height: 1.4,
                      letterSpacing: 0,
                      color: Colors.grey,
                      // opacity: 1 is default
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Colors.black,
                    // opacity: 1 is default
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.searchDescriptionHelper.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32.h),
                // --- What You Are Looking For Section ---
                Text(
                  EnumLocale.whatYouAreLookingForTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _whatYouAreLookingForController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: EnumLocale.whatYouAreLookingForHint.name.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 15.sp,
                      height: 1.4,
                      letterSpacing: 0,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.whatYouAreLookingForHelper.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32.h),
                // --- What You Don't Want Section ---
                Text(
                  EnumLocale.whatYouDontWantTitle.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _whatYouDontWantController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: EnumLocale.whatYouDontWantHint.name.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 15.sp,
                      height: 1.4,
                      letterSpacing: 0,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.whatYouDontWantHelper.name.tr,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 32.h),
                // Passer button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB85C38),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      elevation: 0,
                      ),
                      onPressed: () async {
                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        if (_nameController.text.trim().isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.fullName.name.tr + ' ' + EnumLocale.requiredText.name.tr)),
                          );
                          return;
                        }
                        if (selectedMainInterest == null) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileMainInterestRequired.name.tr)),
                          );
                          return;
                        }
                        if (selectedSecondaryInterests.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileSecondaryInterestRequired.name.tr)),
                          );
                          return;
                        }
                        if (selectedPassions.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profilePassionRequired.name.tr)),
                          );
                          return;
                        }
                        if (_photos.where((p) => p != null).isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profilePhotoRequired.name.tr)),
                          );
                          return;
                        }
                        if (_height < 100) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileHeightRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedSilhouette == null) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileSilhouetteRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedEthnicOrigins.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileEthnicOriginRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedReligions.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileReligionRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedQualities.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileQualityRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedFlaws.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileFlawRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedEnfants == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileChildrenRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedWantEnfants == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileWantChildrenRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedAnimaux == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileAnimalsRequired.name.tr)),
                          );
                          return;
                        }
                        if (selectedLanguages.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileLanguageRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedEducationLevels.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileEducationRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedAlcohol == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileAlcoholRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedSmoking == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileSmokingRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedSnoring == -1) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileSnoringRequired.name.tr)),
                          );
                          return;
                        }
                        if (_selectedHobbies.isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileHobbyRequired.name.tr)),
                          );
                          return;
                        }
                        if (_searchDescriptionController.text.trim().isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileSearchDescriptionRequired.name.tr)),
                          );
                          return;
                        }
                        if (_whatYouAreLookingForController.text.trim().isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileWhatLookingForRequired.name.tr)),
                          );
                          return;
                        }
                        if (_whatYouDontWantController.text.trim().isEmpty) {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.profileWhatNotWantRequired.name.tr)),
                          );
                          return;
                        }
                        // Get the current bloc state to access DOB and location data
                        final blocState = context.read<CreateProfileBloc>().state;
                        // Get country and city from storage
                        final country = GetStorage().read('country') ?? '';
                        final city = GetStorage().read('city') ?? '';
                        // Prepare photo paths
                        List<String> photoPaths = [];
                        for (var photo in _photos) {
                          if (photo != null) {
                            photoPaths.add(photo.path);
                          }
                        }
                        // Get selected options as strings
                        List<String> getSelectedOptions(List<int> selectedIndexes, List<String> options) {
                          return selectedIndexes.map((index) => options[index]).toList();
                        }
                        // Create the complete profile
                        context.read<CreateProfileBloc>().add(CreateCompleteProfile(
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          dob: blocState.dob,
                          gender: blocState.gender,
                          orientation: blocState.orientation ?? '',
                          relationshipStatus: blocState.relationshipStatus ?? '',
                          country: country,
                          city: city,
                          mainInterests: selectedMainInterest != null ? [mainInterests[selectedMainInterest!]] : [],
                          secondaryInterests: getSelectedOptions(selectedSecondaryInterests, secondaryInterests),
                          passions: selectedPassions,
                          photos: photoPaths,
                          height: _height,
                          silhouette: _selectedSilhouette,
                          ethnicOrigins: getSelectedOptions(_selectedEthnicOrigins, [
                            EnumLocale.ethnicAfrican.name.tr, EnumLocale.ethnicArab.name.tr,
                            EnumLocale.ethnicAsian.name.tr, EnumLocale.ethnicEuropean.name.tr,
                            EnumLocale.ethnicLatino.name.tr, EnumLocale.ethnicOther.name.tr,
                          ]),
                          religions: getSelectedOptions(_selectedReligions, [
                            EnumLocale.religionCatholic.name.tr, EnumLocale.religionProtestant.name.tr,
                            EnumLocale.religionIslam.name.tr, EnumLocale.religionAtheist.name.tr,
                            EnumLocale.religionLatino.name.tr, EnumLocale.religionOther.name.tr,
                          ]),
                          qualities: getSelectedOptions(_selectedQualities, [
                            EnumLocale.qualityAutonomous.name.tr, EnumLocale.qualitySociable.name.tr,
                            EnumLocale.qualityFunny.name.tr, EnumLocale.qualityCreative.name.tr,
                            EnumLocale.qualityListener.name.tr, EnumLocale.qualityOther.name.tr,
                          ]),
                          flaws: getSelectedOptions(_selectedFlaws, [
                            EnumLocale.flawPerfectionist.name.tr, EnumLocale.flawImpulsive.name.tr,
                            EnumLocale.flawProcrastination.name.tr, EnumLocale.flawDemanding.name.tr,
                            EnumLocale.flawSensitive.name.tr, EnumLocale.flawOther.name.tr,
                          ]),
                          hasChildren: _selectedEnfants,
                          wantsChildren: _selectedWantEnfants,
                          hasAnimals: _selectedAnimaux,
                          languages: selectedLanguages,
                          educationLevels: getSelectedOptions(_selectedEducationLevels, [
                            EnumLocale.educationNone.name.tr,
                            EnumLocale.educationCollege.name.tr,
                            EnumLocale.educationHighSchool.name.tr,
                            EnumLocale.educationBac.name.tr,
                            EnumLocale.educationBac2.name.tr,
                            EnumLocale.educationLicence.name.tr,
                          ]),
                          alcohol: _selectedAlcohol,
                          smoking: _selectedSmoking,
                          snoring: _selectedSnoring,
                          hobbies: getSelectedOptions(_selectedHobbies, [
                            EnumLocale.hobbySport.name.tr,
                            EnumLocale.hobbyMusic.name.tr,
                            EnumLocale.hobbyPodcasts.name.tr,
                            EnumLocale.hobbyPhotography.name.tr,
                            EnumLocale.hobbyOutings.name.tr,
                            EnumLocale.hobbyArts.name.tr,
                          ]),
                          searchDescription: _searchDescriptionController.text.trim(),
                          whatLookingFor: _whatYouAreLookingForController.text.trim(),
                          whatNotWant: _whatYouDontWantController.text.trim(),
                        ));
                      },
                    child: Text(
                      EnumLocale.nextButton.name.tr,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                              color: Colors.white,
                            ),
                          ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
} 