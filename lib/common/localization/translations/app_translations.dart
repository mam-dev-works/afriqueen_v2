import 'package:afriqueen/common/localization/language/en_us.dart';
import 'package:afriqueen/common/localization/language/fr_fr.dart';
import 'package:get/get.dart';
// FRANCE FR   fr
// UNITED STATES  US  en

// ------------------ To Translate Language Of The App ---------------------
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS, // english language
        'fr_FR': frFR, // france language
      };
}
