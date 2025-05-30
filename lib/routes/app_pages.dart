// ----------------------Route definitions-----------
import 'package:afriqueen/features/create_profile/screen/address_screen.dart';
import 'package:afriqueen/features/create_profile/screen/age_screen.dart';
import 'package:afriqueen/features/create_profile/screen/discription_screen.dart';
import 'package:afriqueen/features/create_profile/screen/gender_screen.dart';
import 'package:afriqueen/features/create_profile/screen/interests_screen.dart';
import 'package:afriqueen/features/create_profile/screen/name_screen.dart';
import 'package:afriqueen/features/create_profile/screen/passion_screen.dart';
import 'package:afriqueen/features/create_profile/screen/upload_image_screen.dart';
import 'package:afriqueen/features/email_verification/screen/email_verification_screen.dart';
import 'package:afriqueen/features/forgot_password/screen/email_sent_screen.dart';
import 'package:afriqueen/features/forgot_password/screen/forgot_password_screen.dart';
import 'package:afriqueen/features/login/screen/login_screen.dart';
import 'package:afriqueen/features/main/screen/main_screen.dart';
import 'package:afriqueen/features/profile/screen/profile_screen.dart';
import 'package:afriqueen/features/setting/screen/setting_screen.dart';
import 'package:afriqueen/features/signup/screen/signup_screen.dart';
import 'package:afriqueen/features/signup/widgets/condition_of_use.dart';
import 'package:afriqueen/features/signup/widgets/privacy_and_policy.dart';
import 'package:afriqueen/features/wellcome/screen/wellcome_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage<dynamic>>? getPages = [
  GetPage(name: AppRoutes.signup, page: () => SignupScreen()),
  GetPage(name: AppRoutes.privacyAndPolicy, page: () => PrivacyAndPolicy()),
  GetPage(name: AppRoutes.conditionOfUse, page: () => ConditionOfUse()),
  GetPage(name: AppRoutes.login, page: () => LoginScreen()),
  GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),
  GetPage(name: AppRoutes.emailSent, page: () => EmailSentScreen()),
  GetPage(
    name: AppRoutes.emailVerification,
    page: () => EmailVerificationScreen(),
  ),

  GetPage(name: AppRoutes.wellcome, page: () => WellcomeScreen()),
  GetPage(name: AppRoutes.main, page: () => MainScreen()),
  GetPage(name: AppRoutes.name, page: () => NameScreen()),
  GetPage(name: AppRoutes.gender, page: () => GenderScreen()),
  GetPage(name: AppRoutes.age, page: () => AgeScreen()),
  GetPage(name: AppRoutes.address, page: () => AddressScreen()),
  GetPage(name: AppRoutes.interests, page: () => InterestsScreen()),
  GetPage(name: AppRoutes.passion, page: () => PassionScreen()),
  GetPage(name: AppRoutes.upload, page: () => UploadImageScreen()),
  GetPage(name: AppRoutes.discription, page: () => DiscriptionScreen()),
  GetPage(name: AppRoutes.setting, page: () => SettingScreen()),
  GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
];
