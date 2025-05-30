import 'package:afriqueen/common/localization/translations/app_translations.dart';
import 'package:afriqueen/common/theme/app_theme.dart';
import 'package:afriqueen/features/create_profile/screen/address_screen.dart';
import 'package:afriqueen/features/create_profile/screen/age_screen.dart';
import 'package:afriqueen/features/create_profile/screen/discription_screen.dart';
import 'package:afriqueen/features/create_profile/screen/gender_screen.dart';
import 'package:afriqueen/features/create_profile/screen/interests_screen.dart';
import 'package:afriqueen/features/create_profile/screen/name_screen.dart';
import 'package:afriqueen/features/create_profile/screen/passion_screen.dart';
import 'package:afriqueen/features/create_profile/screen/upload_image_screen.dart';
import 'package:afriqueen/features/email_verification/screen/email_verification_screen.dart';
import 'package:afriqueen/features/login/screen/login_screen.dart';
import 'package:afriqueen/features/main/screen/main_screen.dart';
import 'package:afriqueen/features/wellcome/screen/wellcome_screen.dart';
import 'package:afriqueen/routes/app_pages.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//---------------------------------MyApp----------------------------------------------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppGetStorage app = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690), // screen size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        title: 'Afriqueen',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        // defaultTransition: Transition.downToUp,
        locale: Locale(app.getLanguageCode()),

        getPages: getPages,
        theme: lightTheme,

        //----------------- checking whether user opening app first time or not--------------------------------
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: SizedBox());
            }

            if (snapShot.hasData) {
              //    ---------------- User is logged in, restore profile creation progress---------------------
              return _pageNumber();
            } else {
              return app.hasOpenedApp() == true
                  ? LoginScreen()
                  : WellcomeScreen();
            }
          },
        ),
      ),
    );
  }

  Widget _pageNumber() {
    switch (app.getPageNumber()) {
      case 1:
        return EmailVerificationScreen();

      case 2:
        return NameScreen();

      case 3:
        return GenderScreen();
      case 4:
        return AgeScreen();
      case 5:
        return AddressScreen();
      case 6:
        return InterestsScreen();
      case 7:
        return PassionScreen();
      case 8:
        return DiscriptionScreen();
      case 9:
        return UploadImageScreen();
      default:
        return MainScreen();
    }
  }
}
