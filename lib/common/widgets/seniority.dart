import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:get/get.dart';

class Seniority {
  static String formatJoinedTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return EnumLocale.joinedJustNow.name.tr;
    } else if (difference.inMinutes < 60) {
      return '${EnumLocale.joined.name.tr} ${difference.inMinutes} ${EnumLocale.minutesAgo.name.tr}';
    } else if (difference.inHours < 24) {
      return '${EnumLocale.joined.name.tr} ${difference.inHours} ${EnumLocale.hoursAgo.name.tr}';
    } else if (difference.inDays < 7) {
      return '${EnumLocale.joined.name.tr} ${difference.inDays} ${EnumLocale.daysAgo.name.tr}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${EnumLocale.joined.name.tr} $weeks week${weeks > 1 ? 's' : ''} ${EnumLocale.ago.name.tr}';
    } else {
      return '${EnumLocale.joinedOn.name.tr} ${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  static String formatStoriesTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '0 ${EnumLocale.minutesAgo.name.tr}';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${EnumLocale.minutesAgo.name.tr}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${EnumLocale.hoursAgo.name.tr}';
    } else {
      return '';
    }
  }
}
