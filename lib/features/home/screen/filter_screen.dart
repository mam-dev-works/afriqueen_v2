import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:afriqueen/features/home/screen/marital_status_screen.dart';
import 'package:afriqueen/features/home/screen/main_interest_screen.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/blocked/repository/blocked_repository.dart';
// Detailed section is now inline; standalone screen import removed

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Filter states
  bool _wantToSee = true;
  bool _wantToBlock = false;
  bool _basicFilter = true;
  bool _detailedFilter = false;
  bool _showDetailed = false; // inline detailed section toggle for "Je veux voir"
  
  // Profile type
  List<String> _selectedProfileTypes = [EnumLocale.profileElite.name.tr];
  
  // Sex
  List<String> _selectedSexes = [EnumLocale.sexWoman.name.tr];
  
  // Sexual orientation
  List<String> _selectedOrientations = [EnumLocale.orientationHetero.name.tr];
  
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
  
  // Detailed filter states (inline)
  RangeValues _heightRange = const RangeValues(140, 220);
  RangeValues _cityDistanceRange = const RangeValues(0, 500);
  String _silhouette = '';
  String _hasChildren = '';
  String _wantsChildren = '';
  String _hasAnimals = '';
  String _alcohol = '';
  String _smoking = '';
  String _snoring = '';
  bool _storyOnly = false;
  bool _atLeast3Photos = false;
  String _createdMoreThan = EnumLocale.allText.name.tr;
  String _createdLessThan = EnumLocale.allText.name.tr;
  String _ethnicOrigin = EnumLocale.allText.name.tr;
  String _astroSign = EnumLocale.allText.name.tr;
  String _religion = EnumLocale.allText.name.tr;
  String _qualities = '';
  String _defects = '';
  String _ownedAnimals = '';
  String _secondaryInterest = '';
  String _passions = '';
  String _hobbies = EnumLocale.allText.name.tr;
  String _professions = EnumLocale.allText.name.tr;
  String _education = EnumLocale.allText.name.tr;
  String _languages = EnumLocale.allText.name.tr;
  String _income = '';
  String _city = '';
  bool _cityDistanceNone = false;
  


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
            Icons.arrow_back,
            color: AppColors.black,
            size: 24.r,
          ),
        ),
        title: Text(
          _wantToBlock ? EnumLocale.filterBlockedTitle.name.tr : EnumLocale.filterViewTitle.name.tr,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto-SemiBold',
          ),
        ),
        centerTitle: true,
      ),
                    body: Padding(
        padding: EdgeInsets.only(bottom: 32.h),
        child: Column(
         children: [
           // Top filter selection
           _buildTopFilterSelection(),
           
           // Main filter content
           Expanded(
             child: SingleChildScrollView(
               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
               child: Column(
                 children: [
                  if (_wantToBlock) ...[
                    // Sexe first
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EnumLocale.filterSex.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterSection('', _buildSexFilter()),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Age
                    _buildFilterSection('', _buildAgeFilter()),
                    SizedBox(height: 12.h),
                    // Orientation
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EnumLocale.filterSexualOrientation.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterSection('', _buildOrientationFilter()),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Distance
                    _buildFilterSection('', _buildDistanceFilter()),
                    SizedBox(height: 12.h),
                    // Marital status
                    _buildFilterSection('', _buildMaritalStatusFilter()),
                    SizedBox(height: 12.h),
                    // Profile
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                                               Text(
                          EnumLocale.filterProfile.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                       SizedBox(height: 12.h),
                                               _buildFilterSection('', _buildProfileTypeFilter()),
                     ],
                   ),
                   SizedBox(height: 12.h),
                    // Non-certified switch
                    _buildFilterSection('', _buildCertifiedFilter()),
                    SizedBox(height: 12.h),
                    // Main interest
                    _buildFilterSection('', _buildMainInterestFilter()),
                  ] else ...[
                    // Original order for "Je veux voir"
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EnumLocale.filterProfile.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _buildFilterSection('', _buildProfileTypeFilter()),
                      ],
                    ),
                    SizedBox(height: 12.h),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                                               Text(
                          EnumLocale.filterSex.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                       SizedBox(height: 12.h),
                                               _buildFilterSection('', _buildSexFilter()),
                     ],
                   ),
                   SizedBox(height: 12.h),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                                               Text(
                          EnumLocale.filterSexualOrientation.name.tr,
                          style: TextStyle(
                            color: Color(0xFF181A1F),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                       SizedBox(height: 12.h),
                                               _buildFilterSection('', _buildOrientationFilter()),
                     ],
                   ),
                   SizedBox(height: 12.h),
                    _buildFilterSection('', _buildAgeFilter()),
                   SizedBox(height: 12.h),
                    _buildFilterSection('', _buildDistanceFilter()),
                   SizedBox(height: 12.h),
                    _buildFilterSection('', _buildMaritalStatusFilter()),
                    SizedBox(height: 12.h),
                    _buildFilterSection('', _buildMainInterestFilter()),
                   SizedBox(height: 12.h),
                    _buildFilterSection('', _buildCertifiedFilter()),
                  ],
                  SizedBox(height: 20.h),
                  // Centered toggle button for detailed filters (inline)
                  SizedBox(
                    width: 200.w,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showDetailed = !_showDetailed;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7BD8E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        _showDetailed
                            ? EnumLocale.filterBasicOnly.name.tr
                            : EnumLocale.filterDetailed.name.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Detailed content inline when enabled under "Je veux voir"
                  if (_wantToSee && _showDetailed) ...[
                    _dfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dfHeader(EnumLocale.dfHeightTitle.name.tr, trailing: EnumLocale.dfHeightTrailing.name.tr),
                          RangeSlider(
                            values: _heightRange,
                            min: 140,
                            max: 220,
                            divisions: 80,
                            activeColor: AppColors.red,
                            inactiveColor: Colors.grey.shade300,
                            onChanged: (v) => setState(() => _heightRange = v),
                          ),
                        ],
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfSilhouetteTitle.name.tr,
                        options: [
                          EnumLocale.dfSilhouetteMince.name.tr,
                          EnumLocale.dfSilhouetteSvelte.name.tr,
                          EnumLocale.dfSilhouetteRonde.name.tr,
                        ],
                        selected: _silhouette,
                        onSelect: (v) => setState(() => _silhouette = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfHasChildrenTitle.name.tr,
                        options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                        selected: _hasChildren,
                        onSelect: (v) => setState(() => _hasChildren = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfWantsChildrenTitle.name.tr,
                        options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                        selected: _wantsChildren,
                        onSelect: (v) => setState(() => _wantsChildren = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfHasAnimalsTitle.name.tr,
                        options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                        selected: _hasAnimals,
                        onSelect: (v) => setState(() => _hasAnimals = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfAlcoholTitle.name.tr,
                        options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr, EnumLocale.dfOptionSometimes.name.tr],
                        selected: _alcohol,
                        onSelect: (v) => setState(() => _alcohol = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfSmokingTitle.name.tr,
                        options: [EnumLocale.yes.name.tr, EnumLocale.no.name.tr, EnumLocale.dfOptionSometimes.name.tr],
                        selected: _smoking,
                        onSelect: (v) => setState(() => _smoking = v),
                      ),
                    ),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfSnoringTitle.name.tr,
                        options: [
                          EnumLocale.yes.name.tr,
                          EnumLocale.no.name.tr,
                          EnumLocale.dfOptionSometimes.name.tr,
                          EnumLocale.dontKnow.name.tr,
                        ],
                        selected: _snoring,
                        onSelect: (v) => setState(() => _snoring = v),
                      ),
                    ),
                    _dfTileSwitch(EnumLocale.dfStoryOnlyTitle.name.tr, _storyOnly, (v) => setState(() => _storyOnly = v)),
                    _dfTileSwitch(EnumLocale.dfAtLeast3PhotosTitle.name.tr, _atLeast3Photos, (v) => setState(() => _atLeast3Photos = v)),
                    _dfPicker(
                      EnumLocale.dfCreatedMoreThanTitle.name.tr,
                      _createdMoreThan,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.time1Day.name.tr,
                        EnumLocale.time7Days.name.tr,
                        EnumLocale.time30Days.name.tr,
                        EnumLocale.time90Days.name.tr,
                      ],
                      (v) => setState(() => _createdMoreThan = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfCreatedLessThanTitle.name.tr,
                      _createdLessThan,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.time1Day.name.tr,
                        EnumLocale.time7Days.name.tr,
                        EnumLocale.time30Days.name.tr,
         
                        EnumLocale.time90Days.name.tr,
                      ],
                      (v) => setState(() => _createdLessThan = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfEthnicOriginTitle.name.tr,
                      _ethnicOrigin,
                      [
                        EnumLocale.ethnicAfrican.name.tr,
                        EnumLocale.ethnicArab.name.tr,
                        EnumLocale.ethnicAsian.name.tr,
                        EnumLocale.ethnicEuropean.name.tr,
                        EnumLocale.ethnicLatino.name.tr,
                        EnumLocale.ethnicOther.name.tr,
                      ],
                      (v) => setState(() => _ethnicOrigin = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfAstroSignTitle.name.tr,
                      _astroSign,
                      [
                        EnumLocale.zodiacAries.name.tr,
                        EnumLocale.zodiacTaurus.name.tr,
                        EnumLocale.zodiacGemini.name.tr,
                        EnumLocale.zodiacCancer.name.tr,
                        EnumLocale.zodiacLeo.name.tr,
                        EnumLocale.zodiacVirgo.name.tr,
                        EnumLocale.zodiacLibra.name.tr,
                        EnumLocale.zodiacScorpio.name.tr,
                        EnumLocale.zodiacSagittarius.name.tr,
                        EnumLocale.zodiacCapricorn.name.tr,
                        EnumLocale.zodiacAquarius.name.tr,
                        EnumLocale.zodiacPisces.name.tr,
                      ],
                      (v) => setState(() => _astroSign = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfReligionTitle.name.tr,
                      _religion,
                      [
                        EnumLocale.religionCatholic.name.tr,
                        EnumLocale.religionProtestant.name.tr,
                        EnumLocale.religionIslam.name.tr,
                        EnumLocale.religionAtheist.name.tr,
                        EnumLocale.religionOther.name.tr,
                      ],
                      (v) => setState(() => _religion = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfQualitiesTitle.name.tr,
                      _qualities.isEmpty ? EnumLocale.allText.name.tr : _qualities,
                      [
                        EnumLocale.qualityAutonomous.name.tr,
                        EnumLocale.qualitySociable.name.tr,
                        EnumLocale.qualityFunny.name.tr,
                        EnumLocale.qualityCreative.name.tr,
                        EnumLocale.qualityListener.name.tr,
                        EnumLocale.qualityOther.name.tr,
                      ],
                      (v) => setState(() => _qualities = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfDefectsTitle.name.tr,
                      _defects.isEmpty ? EnumLocale.allText.name.tr : _defects,
                      [
                        EnumLocale.flawPerfectionist.name.tr,
                        EnumLocale.flawImpulsive.name.tr,
                        EnumLocale.flawProcrastination.name.tr,
                        EnumLocale.flawDemanding.name.tr,
                        EnumLocale.flawSensitive.name.tr,
                        EnumLocale.flawOther.name.tr,
                      ],
                      (v) => setState(() => _defects = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfOwnedAnimalsTitle.name.tr,
                      _ownedAnimals.isEmpty ? EnumLocale.allText.name.tr : _ownedAnimals,
                      [
                        EnumLocale.filterNone.name.tr,
                        EnumLocale.animalDog.name.tr,
                        EnumLocale.animalCat.name.tr,
                        EnumLocale.animalBird.name.tr,
                      ],
                      (v) => setState(() => _ownedAnimals = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfHasChildrenTitle.name.tr,
                      _hasChildren.isEmpty ? EnumLocale.filterNone.name.tr : _hasChildren,
                      [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                      (v) => setState(() => _hasChildren = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfSecondaryInterestTitle.name.tr,
                      _secondaryInterest.isEmpty ? EnumLocale.allText.name.tr : _secondaryInterest,
                      [
                        EnumLocale.secondaryInterestOutings.name.tr,
                        EnumLocale.secondaryInterestChat.name.tr,
                        EnumLocale.secondaryInterestSeriousStory.name.tr,
                        EnumLocale.secondaryInterestFriendship.name.tr,
                        EnumLocale.secondaryInterestFlirt.name.tr,
                        EnumLocale.secondaryInterestAdventure.name.tr,
                      ],
                      (v) => setState(() => _secondaryInterest = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfPassionsTitle.name.tr,
                      _passions.isEmpty ? EnumLocale.allText.name.tr : _passions,
                      [
                        EnumLocale.passionSport.name.tr,
                        EnumLocale.passionVideoGames.name.tr,
                        EnumLocale.passionDuoActivities.name.tr,
                        EnumLocale.passionCinema.name.tr,
                        EnumLocale.passionReading.name.tr,
                        EnumLocale.passionPhotography.name.tr,
                      ],
                      (v) => setState(() => _passions = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfHobbiesTitle.name.tr,
                      _hobbies,
                      [
                        EnumLocale.hobbyAll.name.tr,
                        EnumLocale.hobbySport.name.tr,
                        EnumLocale.hobbyMusic.name.tr,
                        EnumLocale.hobbyReading.name.tr,
                      ],
                      (v) => setState(() => _hobbies = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfProfessionsTitle.name.tr,
                      _professions,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.professionEngineer.name.tr,
                        EnumLocale.professionTeacher.name.tr,
                        EnumLocale.professionStudent.name.tr,
                      ],
                      (v) => setState(() => _professions = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfEducationTitle.name.tr,
                      _education,
                      [
                        EnumLocale.educationNone.name.tr,
                        EnumLocale.educationCollege.name.tr,
                        EnumLocale.educationHighSchool.name.tr,
                        EnumLocale.educationBac.name.tr,
                        EnumLocale.educationBac2.name.tr,
                        EnumLocale.educationLicence.name.tr,
                      ],
                      (v) => setState(() => _education = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfLanguagesTitle.name.tr,
                      _languages,
                      [
                        EnumLocale.languageFrench.name.tr,
                        EnumLocale.languageEnglish.name.tr,
                        EnumLocale.languageSpanish.name.tr,
                        EnumLocale.languageGerman.name.tr,
                      ],
                      (v) => setState(() => _languages = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfIncomeTitle.name.tr,
                      _income.isEmpty ? EnumLocale.allText.name.tr : _income,
                      [
                        EnumLocale.lessThan20000.name.tr,
                        EnumLocale.between20000And40000.name.tr,
                        EnumLocale.between40000And60000.name.tr,
                        EnumLocale.between60000And80000.name.tr,
                        EnumLocale.moreThan200000.name.tr,
                        EnumLocale.preferNotToSay.name.tr,
                      ],
                      (v) => setState(() => _income = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfCityTitle.name.tr,
                      _city.isEmpty ? EnumLocale.allText.name.tr : _city,
                      [
                        EnumLocale.cityLome.name.tr,
                        EnumLocale.cityParis.name.tr,
                        EnumLocale.cityLondon.name.tr,
                        EnumLocale.cityNewYork.name.tr,
                      ],
                      (v) => setState(() => _city = v),
                    ),
                    _dfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dfHeader(EnumLocale.dfCityDistanceTitle.name.tr, trailing: EnumLocale.dfCityDistanceTrailing.name.tr),
                          RangeSlider(
                            values: _cityDistanceRange,
                            min: 0,
                            max: 500,
                            divisions: 50,
                            activeColor: AppColors.red,
                            inactiveColor: Colors.grey.shade300,
                            onChanged: (v) => setState(() => _cityDistanceRange = v),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Detailed content inline when enabled under "Je veux bloquer"
                  if (_wantToBlock && _showDetailed) ...[
                    _dfTileSwitch(EnumLocale.dfProfileWithoutStoryTitle.name.tr, _storyOnly, (v) => setState(() => _storyOnly = v)),
                    _dfTileSwitch(EnumLocale.dfProfileLessThan3PhotosTitle.name.tr, _atLeast3Photos, (v) => setState(() => _atLeast3Photos = v)),
                    _dfPicker(
                      EnumLocale.dfCreatedMoreThanTitle.name.tr,
                      _createdMoreThan,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.time1Day.name.tr,
                        EnumLocale.time7Days.name.tr,
                        EnumLocale.time30Days.name.tr,
                        EnumLocale.time90Days.name.tr,
                      ],
                      (v) => setState(() => _createdMoreThan = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfCreatedLessThanTitle.name.tr,
                      _createdLessThan,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.time1Day.name.tr,
                        EnumLocale.time7Days.name.tr,
                        EnumLocale.time30Days.name.tr,
                        EnumLocale.time90Days.name.tr,
                      ],
                      (v) => setState(() => _createdLessThan = v),
                    ),
                    SizedBox(height: 8.h),
                    _dfHeader(EnumLocale.dfSectionPhysical.name.tr),
                    _dfPicker(
                      EnumLocale.dfEthnicOriginTitle.name.tr,
                      _ethnicOrigin,
                      [
                        EnumLocale.ethnicAfrican.name.tr,
                        EnumLocale.ethnicArab.name.tr,
                        EnumLocale.ethnicAsian.name.tr,
                        EnumLocale.ethnicEuropean.name.tr,
                        EnumLocale.ethnicLatino.name.tr,
                        EnumLocale.ethnicOther.name.tr,
                      ],
                      (v) => setState(() => _ethnicOrigin = v),
                    ),
                    _dfPickerTile(EnumLocale.dfHeightTitle.name.tr, EnumLocale.filterNone.name.tr),
                    _dfCard(
                      child: _dfChipRow(
                        title: EnumLocale.dfSilhouetteTitle.name.tr,
                        options: [
                          EnumLocale.dfSilhouetteMince.name.tr,
                          EnumLocale.dfSilhouetteSvelte.name.tr,
                          EnumLocale.dfSilhouetteRonde.name.tr,
                        ],
                        selected: _silhouette,
                        onSelect: (v) => setState(() => _silhouette = v),
                      ),
                    ),
                    _dfHeader(EnumLocale.dfSectionPersonal.name.tr),
                    _dfPicker(
                      EnumLocale.dfAstroSignTitle.name.tr,
                      _astroSign,
                      [
                        EnumLocale.zodiacAries.name.tr,
                        EnumLocale.zodiacTaurus.name.tr,
                        EnumLocale.zodiacGemini.name.tr,
                        EnumLocale.zodiacCancer.name.tr,
                        EnumLocale.zodiacLeo.name.tr,
                        EnumLocale.zodiacVirgo.name.tr,
                        EnumLocale.zodiacLibra.name.tr,
                        EnumLocale.zodiacScorpio.name.tr,
                        EnumLocale.zodiacSagittarius.name.tr,
                        EnumLocale.zodiacCapricorn.name.tr,
                        EnumLocale.zodiacAquarius.name.tr,
                        EnumLocale.zodiacPisces.name.tr,
                      ],
                      (v) => setState(() => _astroSign = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfCityTitle.name.tr,
                      _city.isEmpty ? EnumLocale.filterNone.name.tr : _city,
                      [
                        EnumLocale.cityLome.name.tr,
                        EnumLocale.cityParis.name.tr,
                        EnumLocale.cityLondon.name.tr,
                        EnumLocale.cityNewYork.name.tr,
                      ],
                      (v) => setState(() => _city = v),
                    ),
                    _dfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _dfHeader(EnumLocale.dfCityDistanceTitle.name.tr, trailing: EnumLocale.dfCityDistanceTrailing.name.tr),
                          RangeSlider(
                            values: _cityDistanceRange,
                            min: 0,
                            max: 500,
                            divisions: 50,
                            activeColor: AppColors.red,
                            inactiveColor: Colors.grey.shade300,
                            onChanged: (v) => setState(() => _cityDistanceRange = v),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _cityDistanceNone,
                                onChanged: (val) => setState(() => _cityDistanceNone = val ?? false),
                                activeColor: const Color(0xFFF7BD8E),
                                side: const BorderSide(color: Color(0xFFF7BD8E), width: 1),
                              ),
                              Text(EnumLocale.filterNone.name.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColors.black)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _dfPicker(
                      EnumLocale.dfReligionTitle.name.tr,
                      _religion,
                      [
                        EnumLocale.religionCatholic.name.tr,
                        EnumLocale.religionProtestant.name.tr,
                        EnumLocale.religionIslam.name.tr,
                        EnumLocale.religionAtheist.name.tr,
                        EnumLocale.religionOther.name.tr,
                      ],
                      (v) => setState(() => _religion = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfQualitiesTitle.name.tr,
                      _qualities.isEmpty ? EnumLocale.filterNone.name.tr : _qualities,
                      [
                        EnumLocale.qualityAutonomous.name.tr,
                        EnumLocale.qualitySociable.name.tr,
                        EnumLocale.qualityFunny.name.tr,
                        EnumLocale.qualityCreative.name.tr,
                        EnumLocale.qualityListener.name.tr,
                        EnumLocale.qualityOther.name.tr,
                      ],
                      (v) => setState(() => _qualities = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfDefectsTitle.name.tr,
                      _defects.isEmpty ? EnumLocale.filterNone.name.tr : _defects,
                      [
                        EnumLocale.flawPerfectionist.name.tr,
                        EnumLocale.flawImpulsive.name.tr,
                        EnumLocale.flawProcrastination.name.tr,
                        EnumLocale.flawDemanding.name.tr,
                        EnumLocale.flawSensitive.name.tr,
                        EnumLocale.flawOther.name.tr,
                      ],
                      (v) => setState(() => _defects = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfOwnedAnimalsTitle.name.tr,
                      _ownedAnimals.isEmpty ? EnumLocale.filterNone.name.tr : _ownedAnimals,
                      [
                        EnumLocale.filterNone.name.tr,
                        EnumLocale.animalDog.name.tr,
                        EnumLocale.animalCat.name.tr,
                        EnumLocale.animalBird.name.tr,
                      ],
                      (v) => setState(() => _ownedAnimals = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfHasChildrenTitle.name.tr,
                      _hasChildren.isEmpty ? EnumLocale.filterNone.name.tr : _hasChildren,
                      [EnumLocale.yes.name.tr, EnumLocale.no.name.tr],
                      (v) => setState(() => _hasChildren = v),
                    ),
                    _dfHeader(EnumLocale.dfSectionInterest.name.tr),
                    _dfPicker(
                      EnumLocale.dfSecondaryInterestTitle.name.tr,
                      _secondaryInterest.isEmpty ? EnumLocale.filterNone.name.tr : _secondaryInterest,
                      [
                        EnumLocale.secondaryInterestOutings.name.tr,
                        EnumLocale.secondaryInterestChat.name.tr,
                        EnumLocale.secondaryInterestSeriousStory.name.tr,
                        EnumLocale.secondaryInterestFriendship.name.tr,
                        EnumLocale.secondaryInterestFlirt.name.tr,
                        EnumLocale.secondaryInterestAdventure.name.tr,
                      ],
                      (v) => setState(() => _secondaryInterest = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfPassionsTitle.name.tr,
                      _passions.isEmpty ? EnumLocale.filterNone.name.tr : _passions,
                      [
                        EnumLocale.passionSport.name.tr,
                        EnumLocale.passionVideoGames.name.tr,
                        EnumLocale.passionDuoActivities.name.tr,
                        EnumLocale.passionCinema.name.tr,
                        EnumLocale.passionReading.name.tr,
                        EnumLocale.passionPhotography.name.tr,
                      ],
                      (v) => setState(() => _passions = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfHobbiesTitle.name.tr,
                      _hobbies,
                      [
                        EnumLocale.hobbyAll.name.tr,
                        EnumLocale.hobbySport.name.tr,
                        EnumLocale.hobbyMusic.name.tr,
                        EnumLocale.hobbyReading.name.tr,
                      ],
                      (v) => setState(() => _hobbies = v),
                    ),
                    _dfHeader(EnumLocale.dfSectionProfession.name.tr),
                    _dfPicker(
                      EnumLocale.dfProfessionsTitle.name.tr,
                      _professions,
                      [
                        EnumLocale.allText.name.tr,
                        EnumLocale.professionEngineer.name.tr,
                        EnumLocale.professionTeacher.name.tr,
                        EnumLocale.professionStudent.name.tr,
                      ],
                      (v) => setState(() => _professions = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfEducationTitle.name.tr,
                      _education,
                      [
                        EnumLocale.educationNone.name.tr,
                        EnumLocale.educationCollege.name.tr,
                        EnumLocale.educationHighSchool.name.tr,
                        EnumLocale.educationBac.name.tr,
                        EnumLocale.educationBac2.name.tr,
                        EnumLocale.educationLicence.name.tr,
                      ],
                      (v) => setState(() => _education = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfLanguagesTitle.name.tr,
                      _languages,
                      [
                        EnumLocale.languageFrench.name.tr,
                        EnumLocale.languageEnglish.name.tr,
                        EnumLocale.languageSpanish.name.tr,
                        EnumLocale.languageGerman.name.tr,
                      ],
                      (v) => setState(() => _languages = v),
                    ),
                    _dfPicker(
                      EnumLocale.dfIncomeTitle.name.tr,
                      _income.isEmpty ? EnumLocale.filterNone.name.tr : _income,
                      [
                        EnumLocale.lessThan20000.name.tr,
                        EnumLocale.between20000And40000.name.tr,
                        EnumLocale.between40000And60000.name.tr,
                        EnumLocale.between60000And80000.name.tr,
                        EnumLocale.moreThan200000.name.tr,
                        EnumLocale.preferNotToSay.name.tr,
                      ],
                      (v) => setState(() => _income = v),
                    ),
                  ],
                 ],
               ),
             ),
           ),
          // Bottom buttons: Retour & Appliquer
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      EnumLocale.retour.name.tr,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Apply filters for "I want to block":
                      if (_wantToBlock) {
                        try {
                          // 1) Update invisibility on current user
                          final homeRepo = HomeRepository();
                          await homeRepo.updateCurrentUserInvisibility(
                            invisibleToProfileTypes: _selectedProfileTypes,
                            invisibleToSexes: _selectedSexes,
                            invisibleToOrientations: _selectedOrientations,
                          );

                          // 2) Find matching users according to selections
                          final matches = await homeRepo.findUsersForBlock(
                            selectedProfileTypes: _selectedProfileTypes,
                            selectedSexes: _selectedSexes,
                            selectedOrientations: _selectedOrientations,
                            ageRange: _ageRange,
                            selectedMaritalStatuses: _selectedMaritalStatuses,
                            selectedMainInterests: _selectedMainInterests,
                          );

                          // 3) Store matched IDs to user's blocked collection
                          final blockedRepo = BlockedRepository();
                          for (final m in matches) {
                            if (m.id.isNotEmpty) {
                              await blockedRepo.addBlockedUser(m.id);
                            }
                          }
                        } catch (e) {
                          // You can show a snackbar if needed
                        }
                      }

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7BD8E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                    ),
                    child: Text(
                      EnumLocale.filterApply.name.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
             ),
           ),
         ],
        ),
      ),
    );
  }

  Widget _buildTopFilterSelection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  EnumLocale.filterWantToSee.name.tr,
                  _wantToSee,
                  () => setState(() {
                    _wantToSee = true;
                    _wantToBlock = false;
                  }),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextButton(
                  EnumLocale.filterWantToBlock.name.tr,
                  _wantToBlock,
                  () => setState(() {
                    _wantToSee = false;
                    _wantToBlock = true;
                  }),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: _buildResetButton(),
          ),
                     SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
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

  Widget _buildTextButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF7BD8E) : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isSelected ? Color(0xFFF7BD8E) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
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

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () {
                 setState(() {
           _selectedProfileTypes = [EnumLocale.profileElite.name.tr];
           _selectedSexes = [EnumLocale.sexWoman.name.tr];
           _selectedOrientations = [EnumLocale.orientationHetero.name.tr];
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
          EnumLocale.filterDeleteAllFilters.name.tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
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
        _buildOvalButton(EnumLocale.filterElite.name.tr, _selectedProfileTypes.contains(EnumLocale.profileElite.name.tr), () {
          setState(() {
            if (_selectedProfileTypes.contains(EnumLocale.profileElite.name.tr)) {
              _selectedProfileTypes.remove(EnumLocale.profileElite.name.tr);
            } else {
              _selectedProfileTypes.add(EnumLocale.profileElite.name.tr);
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton(EnumLocale.filterClassic.name.tr, _selectedProfileTypes.contains(EnumLocale.profileClassic.name.tr), () {
          setState(() {
            if (_selectedProfileTypes.contains(EnumLocale.profileClassic.name.tr)) {
              _selectedProfileTypes.remove(EnumLocale.profileClassic.name.tr);
            } else {
              _selectedProfileTypes.add(EnumLocale.profileClassic.name.tr);
            }
          });
        }),
      ],
    );
  }

  Widget _buildSexFilter() {
    return Row(
      children: [
        _buildOvalButton(EnumLocale.filterMan.name.tr, _selectedSexes.contains(EnumLocale.sexMan.name.tr), () {
          setState(() {
            if (_selectedSexes.contains(EnumLocale.sexMan.name.tr)) {
              _selectedSexes.remove(EnumLocale.sexMan.name.tr);
            } else {
              _selectedSexes.add(EnumLocale.sexMan.name.tr);
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton(EnumLocale.filterWoman.name.tr, _selectedSexes.contains(EnumLocale.sexWoman.name.tr), () {
          setState(() {
            if (_selectedSexes.contains(EnumLocale.sexWoman.name.tr)) {
              _selectedSexes.remove(EnumLocale.sexWoman.name.tr);
            } else {
              _selectedSexes.add(EnumLocale.sexWoman.name.tr);
            }
          });
        }),
      ],
    );
  }

  Widget _buildOrientationFilter() {
    return Row(
      children: [
        _buildOvalButton(EnumLocale.filterHetero.name.tr, _selectedOrientations.contains(EnumLocale.orientationHetero.name.tr), () {
          setState(() {
            if (_selectedOrientations.contains(EnumLocale.orientationHetero.name.tr)) {
              _selectedOrientations.remove(EnumLocale.orientationHetero.name.tr);
            } else {
              _selectedOrientations.add(EnumLocale.orientationHetero.name.tr);
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton(EnumLocale.filterHomo.name.tr, _selectedOrientations.contains(EnumLocale.orientationHomo.name.tr), () {
          setState(() {
            if (_selectedOrientations.contains(EnumLocale.orientationHomo.name.tr)) {
              _selectedOrientations.remove(EnumLocale.orientationHomo.name.tr);
            } else {
              _selectedOrientations.add(EnumLocale.orientationHomo.name.tr);
            }
          });
        }),
        SizedBox(width: 12.w),
        _buildOvalButton(EnumLocale.filterBi.name.tr, _selectedOrientations.contains(EnumLocale.orientationBi.name.tr), () {
          setState(() {
            if (_selectedOrientations.contains(EnumLocale.orientationBi.name.tr)) {
              _selectedOrientations.remove(EnumLocale.orientationBi.name.tr);
            } else {
              _selectedOrientations.add(EnumLocale.orientationBi.name.tr);
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
               EnumLocale.filterAge.name.tr,
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w600,
               ),
             ),
                         Text(
               '${_ageRange.start.round()} ${EnumLocale.filterTo.name.tr} ${_ageRange.end.round()}${EnumLocale.filterPlus.name.tr}',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 11.sp,
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
        // Show "Aucun" option only when "Je veux bloquer" and "Filtre de base" are selected
        if (_wantToBlock && _basicFilter) ...[
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
                EnumLocale.filterNone.name.tr,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
               EnumLocale.filterDistanceFromMe.name.tr,
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 12.sp,
                 fontWeight: FontWeight.w600,
               ),
             ),
                         Text(
               '${EnumLocale.filterFrom.name.tr} ${_distanceRange.start.round()} ${EnumLocale.filterTo.name.tr} ${_distanceRange.end.round()}${EnumLocale.filterPlus.name.tr}',
               style: TextStyle(
                 color: AppColors.black,
                 fontSize: 11.sp,
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
        // Show "Aucun" option only when "Je veux bloquer" and "Filtre de base" are selected
        if (_wantToBlock && _basicFilter) ...[
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
                EnumLocale.filterNone.name.tr,
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
            EnumLocale.filterMaritalStatus.name.tr,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12.sp,
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
            EnumLocale.filterMainInterest.name.tr,
            style: TextStyle(
              color: AppColors.black,
              fontSize: 12.sp,
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
           _wantToBlock ? EnumLocale.filterNonCertifiedProfile.name.tr : EnumLocale.filterCertifiedProfileOnly.name.tr,
           style: TextStyle(
             color: AppColors.black,
             fontSize: 12.sp,
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
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
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
             fontSize: 9.sp,
             fontWeight: FontWeight.w500,
             fontFamily: 'Montserrat',
             height: 1.0,
             letterSpacing: 0,
           ),
         ),
      ),
    );
  }

  // bottom buttons are built inline in the body now to match the design
  Widget _dfCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _dfHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        if (trailing != null)
          Text(trailing, style: TextStyle(color: AppColors.black, fontSize: 11.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _dfChipRow({required String title, required List<String> options, required String selected, required Function(String) onSelect}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.black, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 8.h,
          children: options.map((o) => _dfChip(o, selected == o, () => onSelect(o))).toList(),
        )
      ],
    );
  }

  Widget _dfChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF7BD8E) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? const Color(0xFFF7BD8E) : Colors.grey.shade300),
            ),
            child: Text(
          label,
          style: TextStyle(color: const Color(0xFF181A1F), fontSize: 10.sp, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _dfTileSwitch(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _dfPickerTile(String title, String value, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 12.sp)),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: AppColors.black),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _dfPicker(String title, String value, List<String> options, Function(String) onSelect) {
    return _dfPickerTile(title, value, onTap: () async {
      final selected = await Get.bottomSheet<String>(
        SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: ListView(
              shrinkWrap: true,
              children: options
                  .map((opt) => ListTile(
                        title: Text(opt),
                        onTap: () => Get.back(result: opt),
                      ))
                  .toList(),
            ),
          ),
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      if (selected != null) onSelect(selected);
    });
  }
} 