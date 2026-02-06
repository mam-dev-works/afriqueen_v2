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
      await _handleAuthLink(deepLink, source: "onLink");
    }).onError((error) {
      print('[GLOBAL] onLink error');
      print(error);
    });

    FirebaseDynamicLinks.instance.getInitialLink().then((data) async {
      final Uri? deepLink = data?.link;
      debugPrint("[GLOBAL] getInitialLink deepLink: $deepLink");
      if (deepLink != null) {
        await _handleAuthLink(deepLink, source: "getInitialLink");
      }
    });

    // Handle Firebase Auth links directly
    _initAppLinks();
  }

  void _initAppLinks() {
    final appLinks = AppLinks();
    
    appLinks.uriLinkStream.listen((Uri uri) async {
      debugPrint("[GLOBAL] AppLinks uri: $uri");
      await _handleAuthLink(uri, source: "appLinks");
    }, onError: (error) {
      debugPrint("[GLOBAL] AppLinks error: $error");
    });

    // Check for initial link
    appLinks.getInitialAppLink().then((Uri? uri) async {
      if (uri != null) {
        debugPrint("[GLOBAL] AppLinks initial uri: $uri");
        await _handleAuthLink(uri, source: "appLinksInitial");
      }
    });
  }

  Future<void> _handleAuthLink(Uri uri, {required String source}) async {
    debugPrint("[GLOBAL] $source queryParameters: ${uri.queryParameters}");
    final email = _appGetStorage.getLastEmail();
    debugPrint("[GLOBAL] $source email: $email");

    if (email == null || email.isEmpty) {
      debugPrint("[GLOBAL] $source missing stored email, skipping auth link");
      return;
    }

    final String? linkParam = uri.queryParameters['link'];
    final String emailLink = linkParam ?? uri.toString();
    debugPrint("[GLOBAL] $source emailLink: $emailLink");

    if (!FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      debugPrint("[GLOBAL] $source not a sign-in email link");
      return;
    }

    await _passwordlessLoginServices.handleLink(Uri.parse(emailLink), email, context);
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
