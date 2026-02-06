import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:afriqueen/common/widgets/common_button.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'unified_profile_setup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/create_profile_bloc.dart';
import '../bloc/create_profile_event.dart';

class DobLocationScreen extends StatefulWidget {
  const DobLocationScreen({Key? key}) : super(key: key);

  @override
  State<DobLocationScreen> createState() => _DobLocationScreenState();
}

class _DobLocationScreenState extends State<DobLocationScreen> {
  DateTime selectedDate = DateTime(2010, 1, 1);
  bool isLocateMe = false;
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool isLocating = false;

  @override
  void initState() {
    super.initState();
    isLocateMe = false;
  }

  Future<void> _getLocation() async {
    setState(() { isLocating = true; });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { isLocating = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { isLocating = false; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        countryController.text = placemarks.first.country ?? '';
        cityController.text = placemarks.first.locality ?? '';
      }
    } catch (e) {
      // Optionally show error
    }
    setState(() { isLocating = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                Text(
                  EnumLocale.dobLocationTitle.name.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPicker(
                      context,
                      EnumLocale.dobLocationDayLabel.name.tr,
                      selectedDate.day,
                      1,
                      31,
                      (val) => setState(() => selectedDate = DateTime(selectedDate.year, selectedDate.month, val)),
                    ),
                    SizedBox(width: 12.w),
                    _buildMonthPicker(
                      context,
                      selectedDate.month,
                      (val) => setState(() => selectedDate = DateTime(selectedDate.year, val, selectedDate.day)),
                    ),
                    SizedBox(width: 12.w),
                    _buildPicker(
                      context,
                      EnumLocale.dobLocationYearLabel.name.tr,
                      selectedDate.year,
                      1950,
                      2011,
                      (val) => setState(() => selectedDate = DateTime(val, selectedDate.month, selectedDate.day)),
                    ),
                  ],
                ),
                // Info text (simple gray, no background)
                Padding(
                  padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
                  child: Text(
                    EnumLocale.dobLocationInfoText.name.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      height: 1.0,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ),
                // Checkbox and label (centered horizontally, custom style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: isLocateMe,
                      onChanged: (val) async {
                        setState(() => isLocateMe = val ?? false);
                        if (val == true) {
                          await _getLocation();
                        } else {
                          countryController.clear();
                          cityController.clear();
                        }
                      },
                      activeColor: const Color(0xFFB7410E),
                      checkColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFB7410E), width: 2),
                    ),
                    SizedBox(
                      width: 87.w,
                      height: 18.h,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          EnumLocale.dobLocationLocateMeLabel.name.tr,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            fontSize: 15.sp,
                            height: 1.0,
                            color: const Color(0xFF1C1B1F),
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Help text (centered)
                Text(
                  EnumLocale.dobLocationHelpText.name.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                    color: const Color(0xFF757575),
                  ),
                ),
                SizedBox(height: 16.h),
                // Country input (full width, custom style)
                SizedBox(
                  width: 311.w,
                  height: 34.h,
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: countryController,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: EnumLocale.dobLocationCountryHint.name.tr,
                          hintStyle: TextStyle(
                            color: const Color(0xFF757575),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                          ),
                        ),
                        readOnly: isLocateMe,
                      ),
                      if (isLocating)
                        Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // City input (full width, custom style)
                SizedBox(
                  width: 311.w,
                  height: 34.h,
                  child: TextField(
                    controller: cityController,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 15.sp,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: EnumLocale.dobLocationCityHint.name.tr,
                      hintStyle: TextStyle(
                        color: const Color(0xFF757575),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 15.sp,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
                      ),
                    ),
                    readOnly: isLocateMe,
                  ),
                ),
                SizedBox(height: 32.h),
                // Button (custom style)
                SizedBox(
                  width: 311.w,
                  height: 45.h,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB7410E),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.r),
                        onTap: () {
                          // Save DOB and location data to the bloc
                          context.read<CreateProfileBloc>().add(DobChanged(dob: selectedDate));
                          context.read<CreateProfileBloc>().add(AddressChanged(
                            country: countryController.text,
                            city: cityController.text,
                          ));
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (routeContext) => Builder(
                                builder: (newContext) => BlocProvider.value(
                                  value: BlocProvider.of<CreateProfileBloc>(context),
                                  child: const UnifiedProfileSetupScreen(),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          child: Center(
                            child: Text(
                              EnumLocale.nextButton.name.tr,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPicker(BuildContext context, String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(
          height: 60.h,
          width: 60.w,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            diameterRatio: 1.2,
            perspective: 0.005,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(min + index),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final itemValue = min + index;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: itemValue == value ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    itemValue.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: itemValue == value ? AppColors.primaryColor : Colors.black,
                    ),
                  ),
                );
              },
              childCount: max - min + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker(BuildContext context, int value, ValueChanged<int> onChanged) {
    final months = [
      EnumLocale.dobLocationMonthJan.name.tr,
      EnumLocale.dobLocationMonthFeb.name.tr,
      EnumLocale.dobLocationMonthMar.name.tr,
      EnumLocale.dobLocationMonthApr.name.tr,
      EnumLocale.dobLocationMonthMay.name.tr,
      EnumLocale.dobLocationMonthJun.name.tr,
      EnumLocale.dobLocationMonthJul.name.tr,
      EnumLocale.dobLocationMonthAug.name.tr,
      EnumLocale.dobLocationMonthSep.name.tr,
      EnumLocale.dobLocationMonthOct.name.tr,
      EnumLocale.dobLocationMonthNov.name.tr,
      EnumLocale.dobLocationMonthDec.name.tr,
    ];
    return Column(
      children: [
        Text(EnumLocale.dobLocationMonthLabel.name.tr, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(
          height: 60.h,
          width: 60.w,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            diameterRatio: 1.2,
            perspective: 0.005,
            physics: FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(index + 1),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final isSelected = (index + 1) == value;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    months[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: isSelected ? AppColors.primaryColor : Colors.black,
                    ),
                  ),
                );
              },
              childCount: 12,
            ),
          ),
        ),
      ],
    );
  }
} 