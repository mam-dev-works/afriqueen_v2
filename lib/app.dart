import 'package:afriqueen/common/localization/translations/app_translations.dart';
import 'package:afriqueen/common/theme/app_theme.dart';
import 'package:afriqueen/routes/app_pages.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AppGetStorage _appGetStorage = AppGetStorage();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: 'Afriqueen',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: Locale(_appGetStorage.getLanguageCode()),
        theme: lightTheme,
        defaultTransition: Transition.fade,
        onGenerateRoute: onGenerateRoute,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(); // or splash screen
            }

            final String initialRoute = snapshot.hasData
                ?routeNameFromPageNumber()! 
                : (_appGetStorage.hasOpenedApp()
                    ? AppRoutes.login
                    : AppRoutes.wellcome);

            // Navigate after build
            Future.microtask(() => Get.offAllNamed(initialRoute));

            return const Scaffold(); // placeholder while redirecting
          },
        ),
      ),
    );
  }
}
