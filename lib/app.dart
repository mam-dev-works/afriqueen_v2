import 'package:afriqueen/common/localization/translations/app_translations.dart';
import 'package:afriqueen/common/theme/app_theme.dart';
import 'package:afriqueen/routes/app_pages.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:afriqueen/services/auth/auth_link_handler.dart';
import 'package:afriqueen/services/passwordless_login_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' as getx;
import 'package:app_links/app_links.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:async';

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppGetStorage _appGetStorage = AppGetStorage();
  final PasswordlessLoginServices _passwordlessLoginServices =
      PasswordlessLoginServices();
  late final AuthLinkHandler _authLinkHandler;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<PendingDynamicLinkData>? _dynamicLinkSubscription;
  StreamSubscription<Uri>? _appLinksSubscription;

  @override
  void initState() {
    super.initState();
    _authLinkHandler = AuthLinkHandler(
      auth: FirebaseAuth.instance,
      emailProvider: _appGetStorage.getLastEmail,
      onValidLink: _passwordlessLoginServices.handleLink,
    );
    _initDynamicLinks();
  }

  void _initDynamicLinks() {
    // Handle Firebase Dynamic Links
    _dynamicLinkSubscription = FirebaseDynamicLinks.instance.onLink.listen(
      (dynamicLinkData) async {
        debugPrint("[GLOBAL] onLink dynamicLinkData: $dynamicLinkData");
        final Uri deepLink = dynamicLinkData.link;
        debugPrint("[GLOBAL] onLink deepLink: $deepLink");
        await _handleAuthLink(deepLink, source: "onLink");
      },
      onError: (error) {
        debugPrint('[GLOBAL] onLink error: $error');
      },
    );

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
    _appLinksSubscription = _appLinks.uriLinkStream.listen((Uri uri) async {
      debugPrint("[GLOBAL] AppLinks uri: $uri");
      await _handleAuthLink(uri, source: "appLinks");
    }, onError: (error) {
      debugPrint("[GLOBAL] AppLinks error: $error");
    });

    // Check for initial link
    _appLinks.getInitialAppLink().then((Uri? uri) async {
      if (uri != null) {
        debugPrint("[GLOBAL] AppLinks initial uri: $uri");
        await _handleAuthLink(uri, source: "appLinksInitial");
      }
    });
  }

  Future<void> _handleAuthLink(Uri uri, {required String source}) async {
    debugPrint("[GLOBAL] $source queryParameters: ${uri.queryParameters}");
    final decision = await _authLinkHandler.tryHandle(uri, context: context);

    if (decision == AuthLinkDecision.needsEmail) {
      final email = await _promptForEmail(context);
      if (email == null || email.isEmpty) {
        debugPrint("[GLOBAL] $source email prompt cancelled");
        return;
      }
      _appGetStorage.setLastEmail(email);
      await _authLinkHandler.handleWithEmail(
        uri,
        email: email,
        context: context,
      );
    }
  }

  Future<String?> _promptForEmail(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter your email'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'name@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    return result;
  }

  @override
  void dispose() {
    _dynamicLinkSubscription?.cancel();
    _appLinksSubscription?.cancel();
    super.dispose();
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
                ? routeNameFromPageNumber()!
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
