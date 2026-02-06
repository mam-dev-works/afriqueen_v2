import 'package:afriqueen/common/localization/translations/app_translations.dart';
import 'package:afriqueen/common/theme/app_theme.dart';
import 'package:afriqueen/routes/app_pages.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:afriqueen/services/passwordless_login_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' as getx;
import 'package:app_links/app_links.dart';
import 'package:get/get_core/src/get_main.dart';

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppGetStorage _appGetStorage = AppGetStorage();
  final PasswordlessLoginServices _passwordlessLoginServices = PasswordlessLoginServices();

  @override
  void initState() {
    super.initState();
    // _autoLogin();//todo:remove
    _initDynamicLinks();
  }

  void _autoLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'muradabbaszade143@gmail.com',
        password: 'murad1234',
      );
      debugPrint('Auto-login successful');
    } catch (e) {
      debugPrint('Auto-login failed: \$e');
    }
  }

  void _initDynamicLinks() {
    // Handle Firebase Dynamic Links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      debugPrint("[GLOBAL] onLink dynamicLinkData: $dynamicLinkData");
      final Uri deepLink = dynamicLinkData.link;
      debugPrint("[GLOBAL] onLink deepLink: $deepLink");
      debugPrint("[GLOBAL] onLink queryParameters: ${deepLink.queryParameters}");
      final email = _appGetStorage.getLastEmail();
      debugPrint("[GLOBAL] onLink email: $email");

      if (deepLink != null && email != null && email.isNotEmpty) {
        // Extract the 'link' parameter which contains the actual Firebase Auth email link
        final String? emailLink = deepLink.queryParameters['link'];
        debugPrint("[GLOBAL] onLink extracted emailLink: $emailLink");
        
        if (emailLink != null) {
          await _passwordlessLoginServices.handleLink(Uri.parse(emailLink), email, context);
        } else {
          debugPrint("[GLOBAL] onLink No 'link' parameter found in deepLink");
        }
      }
    }).onError((error) {
      print('[GLOBAL] onLink error');
      print(error);
    });

    FirebaseDynamicLinks.instance.getInitialLink().then((data) async {
      final Uri? deepLink = data?.link;
      debugPrint("[GLOBAL] getInitialLink deepLink: $deepLink");
      debugPrint("[GLOBAL] getInitialLink queryParameters: ${deepLink?.queryParameters}");
      final email = _appGetStorage.getLastEmail();
      debugPrint("[GLOBAL] getInitialLink email: $email");

      if (deepLink != null && email != null && email.isNotEmpty) {
        // Extract the 'link' parameter which contains the actual Firebase Auth email link
        final String? emailLink = deepLink.queryParameters['link'];
        debugPrint("[GLOBAL] getInitialLink extracted emailLink: $emailLink");
        
        if (emailLink != null) {
          await _passwordlessLoginServices.handleLink(Uri.parse(emailLink), email, context);
        } else {
          debugPrint("[GLOBAL] getInitialLink No 'link' parameter found in deepLink");
        }
      }
    });

    // Handle Firebase Auth links directly
    _initAppLinks();
  }

  void _initAppLinks() {
    final appLinks = AppLinks();
    
    appLinks.uriLinkStream.listen((Uri uri) async {
      debugPrint("[GLOBAL] AppLinks uri: $uri");
      debugPrint("[GLOBAL] AppLinks queryParameters: ${uri.queryParameters}");
      
      final email = _appGetStorage.getLastEmail();
      debugPrint("[GLOBAL] AppLinks email: $email");
      
      if (email != null && email.isNotEmpty) {
        final String? emailLink = uri.queryParameters['link'];
        debugPrint("[GLOBAL] AppLinks emailLink: $emailLink");
        
        if (emailLink != null) {
          await _passwordlessLoginServices.handleLink(Uri.parse(emailLink), email, context);
        }
      }
    }, onError: (error) {
      debugPrint("[GLOBAL] AppLinks error: $error");
    });

    // Check for initial link
    appLinks.getInitialAppLink().then((Uri? uri) async {
      if (uri != null) {
        debugPrint("[GLOBAL] AppLinks initial uri: $uri");
        debugPrint("[GLOBAL] AppLinks initial queryParameters: ${uri.queryParameters}");
        
        final email = _appGetStorage.getLastEmail();
        debugPrint("[GLOBAL] AppLinks initial email: $email");
        
        if (email != null && email.isNotEmpty) {
          final String? emailLink = uri.queryParameters['link'];
          debugPrint("[GLOBAL] AppLinks initial emailLink: $emailLink");
          
          if (emailLink != null) {
            await _passwordlessLoginServices.handleLink(Uri.parse(emailLink), email, context);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => getx.GetMaterialApp(
        title: 'Afriqueen',
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: Locale(_appGetStorage.getLanguageCode()),
        theme: lightTheme,
        defaultTransition: getx.Transition.fade,
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
        // home: BlocProvider(
        //   create: (_) => CreateProfileBloc(
        //     repository: CreateProfileRepository(),
        //   ),
        //   child: DobLocationScreen(),
        // ),
      ),
    );
  }
}
