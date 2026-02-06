// ---------------------Contstant Strings----------------

import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:get/get.dart';

class AppStrings {
  //---------------  image  path strings-------------------
  static const String logoImage = 'assets/images/logo.png';
  static const String googleLogo = 'assets/images/google_logo.svg';
  static const String email = 'assets/images/email.json';
  static const String emailVerifed = 'assets/images/email_verifed.json';
  static const String couple = 'assets/images/couple.png';
  static const String us = 'assets/images/country/us.png';
  static const String fr = 'assets/images/country/fr.png';
  static const String uploadImage = 'assets/images/upload_image.json';

  //---------------- fonts  path strings-------------------------

  static const String robotoLight = 'assets/fonts/Roboto-Light.ttf';
  static const String robotosSemiBold = 'assets/fonts/Roboto-SemiBold.ttf';
  static const String robotThin = 'assets/fonts/Roboto-Thin.ttf';

  //-----------------User interests -----------------------------
  static Map<String, List<String>> categorizedUserInterests = {
    "Friendship": [
      EnumLocale.chatting.name.tr,
      EnumLocale.makingNewFriends.name.tr,
      EnumLocale.studyBuddy.name.tr,
      EnumLocale.movieNights.name.tr,
      EnumLocale.coffeeHangouts.name.tr,
    ],
    "Love & Romance": [
      EnumLocale.romanticDates.name.tr,
      EnumLocale.candlelight.name.tr,
      EnumLocale.sweet.name.tr,
      EnumLocale.slowDancing.name.tr,
      EnumLocale.loveLetters.name.tr,
    ],
    "Sports & Outdoors": [
      EnumLocale.football.name.tr,
      EnumLocale.yoga.name.tr,
      EnumLocale.hiking.name.tr,
      EnumLocale.running.name.tr,
      EnumLocale.cycling.name.tr,
    ],
    "Food & Restaurants": [
      EnumLocale.foodie.name.tr,
      EnumLocale.streetFood.name.tr,
      EnumLocale.fineDining.name.tr,
      EnumLocale.coffeeLover.name.tr,
      EnumLocale.baking.name.tr,
    ],
    "Adventure & Travel": [
      EnumLocale.backpacking.name.tr,
      EnumLocale.roadTrips.name.tr,
      EnumLocale.soloTravel.name.tr,
      EnumLocale.camping.name.tr,
      EnumLocale.cityBreaks.name.tr,
    ],
    "Passion": [
      EnumLocale.music.name.tr,
      EnumLocale.creativity.name.tr,
      EnumLocale.fitness.name.tr,
      EnumLocale.travel.name.tr,
      EnumLocale.fashion.name.tr,
    ]
  };

  static const List<String> language = ["English", "Français"];
  static const cloudName = "dv4p4ll3u";
  static const uploadPreset = "afriqueen";

  static List<String> characterTraits = [
    EnumLocale.friendly.name.tr,
    EnumLocale.ambitious.name.tr,
    EnumLocale.creative.name.tr,
    EnumLocale.organized.name.tr,
    EnumLocale.adventurous.name.tr,
    EnumLocale.patient.name.tr,
    EnumLocale.honest.name.tr,
    EnumLocale.reliable.name.tr,
    EnumLocale.optimistic.name.tr,
    EnumLocale.empathetic.name.tr,
    EnumLocale.confident.name.tr,
    EnumLocale.humble.name.tr,
    EnumLocale.passionate.name.tr,
    EnumLocale.determined.name.tr,
    EnumLocale.adaptable.name.tr,
  ];

  static List<String> religions = [
    EnumLocale.christianity.name.tr,
    EnumLocale.islam.name.tr,
    EnumLocale.hinduism.name.tr,
    EnumLocale.buddhism.name.tr,
    EnumLocale.judaism.name.tr,
    EnumLocale.sikhism.name.tr,
    EnumLocale.taoism.name.tr,
    EnumLocale.confucianism.name.tr,
    EnumLocale.shinto.name.tr,
    EnumLocale.otherReligion.name.tr,
  ];

  static List<String> levelOfStudy = [
    EnumLocale.highSchool.name.tr,
    EnumLocale.associateDegree.name.tr,
    EnumLocale.bachelorsDegree.name.tr,
    EnumLocale.mastersDegree.name.tr,
    EnumLocale.doctorate.name.tr,
    EnumLocale.postDoctorate.name.tr,
    EnumLocale.professionalCertification.name.tr,
    EnumLocale.tradeSchool.name.tr,
    EnumLocale.selfTaught.name.tr,
    EnumLocale.otherStudy.name.tr,
  ];

  static List<String> incomeLevel = [
    EnumLocale.lessThan20000.name.tr,
    EnumLocale.between20000And40000.name.tr,
    EnumLocale.between40000And60000.name.tr,
    EnumLocale.between60000And80000.name.tr,
    EnumLocale.between80000And100000.name.tr,
    EnumLocale.between100000And150000.name.tr,
    EnumLocale.between150000And200000.name.tr,
    EnumLocale.moreThan200000.name.tr,
    EnumLocale.preferNotToSay.name.tr,
  ];

  static List<String> ethnicOrigins = [
    EnumLocale.african.name.tr,
    EnumLocale.asian.name.tr,
    EnumLocale.caucasian.name.tr,
    EnumLocale.hispanic.name.tr,
    EnumLocale.middleEastern.name.tr,
    EnumLocale.mixed.name.tr,
    EnumLocale.nativeAmerican.name.tr,
    EnumLocale.pacificIslander.name.tr,
    EnumLocale.otherEthnic.name.tr,
  ];

  static List<String> silhouettes = [
    EnumLocale.athletic.name.tr,
    EnumLocale.average.name.tr,
    EnumLocale.curvy.name.tr,
    EnumLocale.slim.name.tr,
    EnumLocale.muscular.name.tr,
    EnumLocale.plusSize.name.tr,
    EnumLocale.petite.name.tr,
    EnumLocale.tall.name.tr,
    EnumLocale.otherSilhouette.name.tr,
  ];
}
