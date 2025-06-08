// ---------------  All The NAME   Constant   String -----------

enum EnumLocale {
  appName,
  signupText,
  loginText,
  emailHint,
  passwordHint,
  weakPassword,
  emailAlreadyExists,
  emailRequiredText,
  invalidEmailText,
  passwordRequiredText,
  passwordLengthText,
  passwordUppercaseRequiredText,
  passwordLowercaseRequiredText,
  passwordDigitRequiredText,
  passwordSpecialCharacterRequiredText,
  registeringDescriptionText1,
  registeringDescriptionText2,
  registeringDescriptionText3,
  registeringDescriptionText4,
  googleSignInCancelled,
  acceptPolicyAndCondition,
  doNotHaveAccount,
  alreadyHaveAccount,
  privacyTitle,
  privacyBody,
  conditionOfUseTitle,
  conditionOfUseBody,
  userNotFoundError,
  wrongPasswordError,
  defaultError,
  loginWithGoogle,
  forgotPassword,
  passwordChangeSuccess,
  passwordResetInstruction,
  rememberPassword,
  sendButtonText,
  emailSent,
  checkEmail,
  didNotReceiveTheLink,
  resend,
  verifyEmailTitle,
  verifyEmailBody,
  verifyYourEmailText,
  deleteAccountText,
  delete,
  deleteSuccessful,
  loginSuccessful,
  signupSuccessful,
  emailVerifyRequired,
  welcome,
  welcomeDescriptionText,
  next,
  locationPermissionRequired,
  nameHintText,
  nameTitle,
  nameDescription,
  pseudoRequired,
  pseudoLengthError,
  pseudoOnlyContains,
  genderTitle,
  genderDescription,
  genderMale,
  genderFemale,
  dobTitle,
  dobDescription,
  setYourDob,
  ageErrorText,
  addressTitle,
  addressDescription,
  countryName,
  cityName,

  // Interests
  friendshipInterests,
  loveAndRomanceInterests,
  passionAndPersonalityInterests,
  sportsAndOutdoorsInterests,
  foodAndRestaurantsInterests,
  adventureAndTravelInterests,
  interestTitle,
  interestsRequired,
  chooseOption,
  passion,

  // Tags or interest types
  music,
  creativity,
  fitness,
  travel,
  fashion,
  chatting,
  makingNewFriends,
  studyBuddy,
  movieNights,
  coffeeHangouts,
  romanticDates,
  candlelight,
  sweet,
  slowDancing,
  loveLetters,
  football,
  yoga,
  hiking,
  running,
  cycling,
  foodie,
  streetFood,
  fineDining,
  coffeeLover,
  baking,
  backpacking,
  roadTrips,
  soloTravel,
  camping,
  cityBreaks,

  // Image and description
  selectLimit,
  uploadImageTitle,
  uploadImageDescription,
  submit,
  storagePermissionRequired,
  photosPermissionDeniedText,
  descriptionTitle,
  descriptionBody,
  descriptionLabelText,

  // Time-related
  joinedJustNow,
  joined,
  minutesAgo,
  hoursAgo,
  daysAgo,
  ago,
  joinedOn,

  // Settings
  settings,
  logout,
  notifications,
  privacySettings,
  helpCenter,
  changeLanguage,
  favorites,
  archive,
  block,
  report,
  more,
  blocked,
  addStory,
  like,
  message,
  Favorite,
  blockTitle,
  yesBlock,
  cancel,
  yourStory,
  addPhoto,
  savedToFavorites,
  savedToArchives,
  removedFromFavorites,
  removedFromArchives,
  removed,
  storyAdded,
  noDataFound,
  follow,
  following,
  noDataAvailable
}

/*abstract class AppStrings {
  static const String appName = "TrueMatch";
  static const String welcome = "Welcome back!";
  static const String login = "Log In";
  static const String signup = "Sign Up";

  static const String doNotHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String loginWithGoogle = "Continue with Google";
  static const String loginDescription = "\nLet’s find your vibe again.";

  //  error strings
  static const String emailError = "Invalid Email";
  static const List<String> passwordErrors = [
    'Password cannot be empty',
    'Password must be at least 8 characters long',
    'Password must contain at least one number',
    'Password must contain at least one letter',
    'Password must contain at least one special symbol',
  ];

  static const String userNotFound = 'user-not-found';
  static const String userNotFoundMessage = "No user found for that email.";
  static const String wrongPassword = 'wrong-password';
  static const String wrongPasswordMessage =
      'Wrong password provided for that user.';
  static const String validForm = "Form is valid";
  static const String invalidForm = "Form is invalid";
  // signup strings

  static const String join = "Join TrueMatch";
  static const String signupDescription = "\nStart your story with TrueMatch.";

  // hint texts

  static const String emailHint = "Email";
  static const String passwordHint = "Password";
  static const String nameHint = "Name";

  // name
  static const List<String> nameErrors = [
    'Name cannot be empty',
    'Name must be at least 4 characters long',
    'Name must start with a letter',
  ];

  // PASSWORD

  static const String weakPassword = 'weak-password';
  static const String weakPasswordMessage =
      'The password provided is too weak.';
  static const String emailAlreadyExists = 'email-already-in-use';
  static const String emailAlreadyExistsMessage =
      'The account already exists for that email.';

  // signup successful
  static const String successfulSignup = " Signup  Successfull";
  //login
  static const String successfulLogin = " Login  Successfull";
  static const String failed = "something went wrong please try again";

  // image path
  static const String logoImage = "assets/images/logo.svg";
  static const String coupleImage = "assets/images/couple.png";

  static const String googleLogoImage = "assets/images/google_logo.svg";
  static const List<String> conditionOfUseTexts = [
    "TrueMatch – Terms and Conditions of Use\n",
    """
By using TrueMatch, you agree to the following terms and conditions. These terms govern your access to and use of the TrueMatch app and services. Please read them carefully.

1. Eligibility: TrueMatch is only available to users who are 18 years of age or older. By using the app, you confirm that you meet this age requirement and are legally able to enter into a binding agreement.

2. User Responsibilities: You are responsible for all activity that occurs under your account. You agree to provide accurate, truthful information, and to behave respectfully toward other users. Misuse of the app, including but not limited to harassment, impersonation, or posting inappropriate content, may result in suspension or permanent ban.

3. Account Security: You are responsible for maintaining the confidentiality of your login credentials. Any activity under your account will be considered your responsibility. If you suspect unauthorized access, you must notify us immediately.

4. Content and Usage Rights: While you retain ownership of the content (photos, bio, messages, etc.) you upload, you grant TrueMatch a worldwide, non-exclusive, royalty-free license to use and display your content within the app for the purpose of delivering its matchmaking services.

5. Paid Features: Some features in TrueMatch are available through paid subscriptions. Payments are processed via the respective app store (Google Play or App Store). Subscriptions may automatically renew unless cancelled before the end of the billing period. Refunds follow the platform’s policy.

6. Prohibited Behavior: You must not use TrueMatch for illegal or harmful activities. This includes spamming, distributing malware, stalking, soliciting money, or using bots or scripts to manipulate features. Any violation of these rules may lead to immediate termination of your account.

7. Termination: TrueMatch reserves the right to suspend or terminate any account at any time for violation of these terms or for any conduct that may harm the community or the app’s reputation.

8. Limitation of Liability: The app is provided “as is” without warranties of any kind. We do not guarantee that you will find a match or that every user’s profile is genuine. We are not responsible for any damages, losses, or disputes that may arise from using the app.

9. Privacy: Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your personal information.

10. Changes to Terms: We may update these terms from time to time. Your continued use of the app after any update constitutes your acceptance of the new terms. You are encouraged to review them periodically.

11. Governing Law: These terms shall be governed by and interpreted in accordance with the laws of [Insert Country or State]. Any disputes will be handled in the appropriate courts of that jurisdiction.

12. Contact Information: If you have questions about these terms, please contact us at support@truematch.app.""",
  ];
  static const List<String> registeringDescriptionTexts = [
    "By registering, you accept out",
    "Terms and",
    "Conditions of Use",
    "and our",
    "Privacy Policy",
  ];
  static const List<String> appPolicyTexts = [
    "TrueMatch Privacy Policy",
    """


At TrueMatch, we respect and protect the privacy of our users. When you use our app, we collect certain information to improve your experience and provide matchmaking services tailored to your preferences. This includes details you provide such as your name, email address, gender, photos, bio, and dating preferences. We also collect data about your activity within the app, such as the profiles you view, messages you send, and other interactions, along with technical data like device type, location (if enabled), and usage statistics.

Your information helps us personalize recommendations, improve our features, maintain the security of our platform, and ensure your experience is safe and enjoyable. Some information, such as profile data, may be shared with other users to facilitate matches. We also work with trusted third-party providers for hosting, analytics, and payment processing; however, we never sell your personal data to advertisers or outside entities.

You are always in control of your data. You can update or delete your profile, disable location sharing, and even request account deletion at any time. TrueMatch uses secure technologies to protect your information, including encryption and regular security checks, but we also encourage users to take personal precautions such as safeguarding login credentials.

TrueMatch is intended strictly for individuals aged 18 or older. We do not knowingly collect or process data from minors. By using our app, you agree to this privacy policy and any future updates we may apply. If changes are made to how we handle your data, we’ll notify you through the app or email.

If you have any questions or concerns about how we use your information, you can contact us at privacy@truematch.app.
""",
  ];

  // name


  // age error
  static const String ageErrorText = "Age must be greater than 18";
  static const List<String> heightDetailsTexts = [
    "How tall are you?",
    "You can change or delete your answe at anytime.",
  ];

  // feet
  static String feetSuffix = " (feet)";
  static String welcomeDescriptionText =
      """Welcome to TrueMatch! Ready to meet some great people? Tell us a bit about yourself and what you're looking for. Keep it real, share a smile in your pic, and start exploring. Your next connection could be just a swipe away!""";

  // gender

  static const List<String> genderDescriptionTexts = [
    "How do you identify yourself?",
    "You can change this information later by contacting our Customer service department.",
  ];

  // like to meet
  static const List<String> likeToMeetDetailsTexts = [
    "I'd like to meet",
    "Select one options.",
    """By moving forward,you accept that TrueMatch will have access to information relating to your sexual orientation in order to provide its services.""",
  ];

  // no internet
  static const String noInternetImage = "assets/images/connectiviyLoss.json";
  static const String connectionOnlineMessage =
      "Your internet connection was restored";
  static const String connectionOfflineMessage = "You are currently offline";

  // refresh
  static const String refreshButtonText = "Refresh";
  // add photos


  // add image
  static const String uploadImageIcon = "assets/images/uploadImage.json";

  // interest
  static const String interestLabelText =
      "Choose a variety of keyboards that best reflect your interests.";
  static const List<String> userInterestOptions = [
    "Traveling",
    "Cooking",
    "Music",
    "Movies",
    "Fitness",
    "Reading",
    "Pet Lover",
    "Photography",
    "Adventure",
    "Coffee Lover",
  ];

  // submit
  static const String submitButtonText = "Submit";

  // cloudinary
  static const String cloudName = "tbistaxmok1";
  static const String uploadPreset = "q8cbytay";
  static const String folderName = "images";

  // permission
  static const String photosPermissionDeniedText =
      "Permission is denied for photos";
      static const String photosPermissionPermanentlyDeniedText =
      "Permission is permanently  denied for photos";

      // profile complete
        static const String completeYourProfileText =
      "Complete your profile to continue the process...";
      // profile not found
      static const profileNotFound = "No profile found.";
      static const errorOccurMesssage = "An error occurred.";
}
// debug
// keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android*/

// release
//keytool -genkey -v -keystore my_release_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my_key_alias
