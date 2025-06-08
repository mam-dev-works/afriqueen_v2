import 'package:afriqueen/features/archive/bloc/archive_bloc.dart';
import 'package:afriqueen/features/archive/bloc/archive_event.dart';
import 'package:afriqueen/features/archive/repository/archive_repository.dart';
import 'package:afriqueen/features/archive/screen/archive_screen.dart';
import 'package:afriqueen/features/create_profile/bloc/create_profile_bloc.dart';
import 'package:afriqueen/features/create_profile/repository/create_profile_repository.dart';
import 'package:afriqueen/features/create_profile/screen/address_screen.dart';
import 'package:afriqueen/features/create_profile/screen/age_screen.dart';
import 'package:afriqueen/features/create_profile/screen/description_screen.dart';
import 'package:afriqueen/features/create_profile/screen/gender_screen.dart';
import 'package:afriqueen/features/create_profile/screen/interests_screen.dart';
import 'package:afriqueen/features/create_profile/screen/name_screen.dart';
import 'package:afriqueen/features/create_profile/screen/passion_screen.dart';
import 'package:afriqueen/features/create_profile/screen/upload_image_screen.dart';
import 'package:afriqueen/features/email_verification/bloc/email_verification_bloc.dart';
import 'package:afriqueen/features/email_verification/repository/email_verification_repository.dart';
import 'package:afriqueen/features/email_verification/screen/email_verification_screen.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_bloc.dart';
import 'package:afriqueen/features/favorite/bloc/favorite_event.dart';
import 'package:afriqueen/features/favorite/repository/favorite_repository.dart';
import 'package:afriqueen/features/favorite/screen/favorite_screen.dart';
import 'package:afriqueen/features/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:afriqueen/features/forgot_password/repository/forgot_password_repository.dart';
import 'package:afriqueen/features/forgot_password/screen/email_sent_screen.dart';
import 'package:afriqueen/features/forgot_password/screen/forgot_password_screen.dart';
import 'package:afriqueen/features/home/bloc/home_bloc.dart';
import 'package:afriqueen/features/home/bloc/home_event.dart';
import 'package:afriqueen/features/home/repository/home_repository.dart';
import 'package:afriqueen/features/login/bloc/login_bloc.dart';
import 'package:afriqueen/features/login/repository/login_repository.dart';
import 'package:afriqueen/features/login/screen/login_screen.dart';
import 'package:afriqueen/features/main/screen/main_screen.dart';
import 'package:afriqueen/features/profile/bloc/profile_bloc.dart';
import 'package:afriqueen/features/profile/bloc/profile_event.dart';
import 'package:afriqueen/features/profile/repository/profile_repository.dart';
import 'package:afriqueen/features/profile/screen/profile_screen.dart';
import 'package:afriqueen/features/setting/screen/setting_screen.dart';
import 'package:afriqueen/features/signup/bloc/signup_bloc.dart';
import 'package:afriqueen/features/signup/repository/signup_repository.dart';
import 'package:afriqueen/features/signup/screen/signup_screen.dart';
import 'package:afriqueen/features/signup/widgets/condition_of_use.dart';
import 'package:afriqueen/features/signup/widgets/privacy_and_policy.dart';
import 'package:afriqueen/features/stories/bloc/stories_bloc.dart';
import 'package:afriqueen/features/stories/bloc/stories_event.dart';
import 'package:afriqueen/features/stories/repository/stories_repository.dart';
import 'package:afriqueen/features/wellcome/bloc/wellcome_bloc.dart';
import 'package:afriqueen/features/wellcome/screen/wellcome_screen.dart';
import 'package:afriqueen/routes/app_routes.dart';
import 'package:afriqueen/services/storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Group all your screen imports here for clarity
final AppGetStorage app = AppGetStorage();

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.signup:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          lazy: true,
          create: (context) => SignupRepository(),
          child: BlocProvider(
            create: (context) =>
                SignupBloc(signupRepository: context.read<SignupRepository>()),
            child: SignupScreen(),
          ),
        ),
      );

    case AppRoutes.privacyAndPolicy:
      return MaterialPageRoute(builder: (_) => PrivacyAndPolicy());

    case AppRoutes.conditionOfUse:
      return MaterialPageRoute(builder: (_) => ConditionOfUse());

    case AppRoutes.login:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          lazy: true,
          create: (context) => LoginRepository(),
          child: BlocProvider(
            create: (context) =>
                LoginBloc(loginrepository: context.read<LoginRepository>()),
            child: LoginScreen(),
          ),
        ),
      );
    // forgot password part
    case AppRoutes.forgotPassword:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => ForgotPasswordRepository(),
          child: BlocProvider(
            create: (context) => ForgotPasswordBloc(
              repo: context.read<ForgotPasswordRepository>(),
            ),
            child: ForgotPasswordScreen(),
          ),
        ),
      );
    case AppRoutes.emailSent:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => ForgotPasswordRepository(),
          child: BlocProvider(
            create: (context) => ForgotPasswordBloc(
              repo: context.read<ForgotPasswordRepository>(),
            ),
            child: EmailSentScreen(),
          ),
        ),
      );

    case AppRoutes.emailVerification:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          lazy: true,
          create: (context) => EmailVerificationRepository(),
          child: BlocProvider(
            create: (context) => EmailVerificationBloc(
              repository: context.read<EmailVerificationRepository>(),
            ),
            child: EmailVerificationScreen(),
          ),
        ),
      );
    case AppRoutes.wellcome:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => WellcomeBloc(),
          child: WellcomeScreen(),
        ),
      );
    case AppRoutes.main:
      return MaterialPageRoute(
        builder: (_) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (_) => HomeRepository(),
            ),
            RepositoryProvider(
              create: (context) => StoriesRepository(),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => HomeBloc(
                  repo: context.read<HomeRepository>(),
                )
                  ..add(HomeUsersProfileList())
                  ..add(HomeUsersFetched()),
              ),
              BlocProvider(
                create: (context) => StoriesBloc(
                  repo: context.read<StoriesRepository>(),
                )..add(StoriesFetching()),
              ),
            ],
            child: MainScreen(),
          ),
        ),
      );

    // Create Profile Flow (CreateProfileBloc shared across screens)
    case AppRoutes.name:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: NameScreen(),
          ),
        ),
      );

    // The following should use `BlocProvider.value()` in real flows
    case AppRoutes.gender:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: GenderScreen(),
          ),
        ),
      );
    case AppRoutes.age:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: AgeScreen(),
          ),
        ),
      );
    case AppRoutes.address:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: AddressScreen(),
          ),
        ),
      );
    case AppRoutes.interests:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: InterestsScreen(),
          ),
        ),
      );
    case AppRoutes.passion:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: PassionScreen(),
          ),
        ),
      );

    case AppRoutes.upload:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: UploadImageScreen(),
          ),
        ),
      );
    case AppRoutes.description:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => CreateProfileRepository(),
          child: BlocProvider(
            create: (context) => CreateProfileBloc(
              repository: context.read<CreateProfileRepository>(),
            ),
            child: DescriptionScreen(),
          ),
        ),
      );
    case AppRoutes.setting:
      return MaterialPageRoute(builder: (_) => SettingScreen());
    case AppRoutes.profile:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (context) => ProfileRepository(),
          child: BlocProvider(
            create: (context) =>
                ProfileBloc(repo: context.read<ProfileRepository>())
                  ..add(ProfileFetch()),
            child: ProfileScreen(),
          ),
        ),
      );
    case AppRoutes.favorite:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => FavoriteRepository(),
          child: BlocProvider(
            create: (context) => FavoriteBloc(
              repository: context.read<FavoriteRepository>(),
            )..add(FavoriteUsersFetched()),
            child: FavoriteScreen(),
          ),
        ),
      );
    case AppRoutes.archive:
      return MaterialPageRoute(
        builder: (_) => RepositoryProvider(
          create: (_) => ArchiveRepository(),
          child: BlocProvider(
            create: (context) => ArchiveBloc(
              repository: context.read<ArchiveRepository>(),
            )..add(ArchiveUsersFetched()),
            child: ArchiveScreen(),
          ),
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => WellcomeBloc(),
          child: WellcomeScreen(),
        ),
      );
  }
}

String? routeNameFromPageNumber() {
  switch (app.getPageNumber()) {
    case 1:
      return AppRoutes.emailVerification;
    case 2:
      return AppRoutes.name;
    case 3:
      return AppRoutes.gender;
    case 4:
      return AppRoutes.age;
    case 5:
      return AppRoutes.address;
    case 6:
      return AppRoutes.interests;
    case 7:
      return AppRoutes.passion;
    case 8:
      return AppRoutes.description;
    case 9:
      return AppRoutes.upload;
    default:
      return AppRoutes.main;
  }
}
