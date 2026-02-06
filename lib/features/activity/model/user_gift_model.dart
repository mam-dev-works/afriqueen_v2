import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';

class UserGiftModel {
  final String giftType;
  final int remainingCount;
  final bool isPremium;
  final DateTime? lastRechargeTime;

  UserGiftModel({
    required this.giftType,
    required this.remainingCount,
    this.isPremium = false,
    this.lastRechargeTime,
  });

  factory UserGiftModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserGiftModel(
      giftType: doc.id,
      remainingCount: data['remainingCount'] ?? data['remaining'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      lastRechargeTime: (data['lastRechargeTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'remainingCount': remainingCount,
      'isPremium': isPremium,
      'lastRechargeTime': lastRechargeTime != null ? Timestamp.fromDate(lastRechargeTime!) : null,
    };
  }

  UserGiftModel copyWith({
    String? giftType,
    int? remainingCount,
    bool? isPremium,
    DateTime? lastRechargeTime,
  }) {
    return UserGiftModel(
      giftType: giftType ?? this.giftType,
      remainingCount: remainingCount ?? this.remainingCount,
      isPremium: isPremium ?? this.isPremium,
      lastRechargeTime: lastRechargeTime ?? this.lastRechargeTime,
    );
  }
}

// Default gift types with their display names
class GiftTypes {
  static Map<String, String> get giftNames => {
    'rose': EnumLocale.giftTypeRose.name.tr,
    'chocolat': EnumLocale.giftTypeChocolat.name.tr,
    'bouquet': EnumLocale.giftTypeBouquet.name.tr,
    'vetement': EnumLocale.giftTypeVetement.name.tr,
    'coeur': EnumLocale.giftTypeCoeur.name.tr,
    'bague': EnumLocale.giftTypeBague.name.tr,
    'papillon': EnumLocale.giftTypePapillon.name.tr,
    'trophee': EnumLocale.giftTypeTrophee.name.tr,
    'donut': EnumLocale.giftTypeDonut.name.tr,
    'pizza': EnumLocale.giftTypePizza.name.tr,
    'sac': EnumLocale.giftTypeSac.name.tr,
    'chiot': EnumLocale.giftTypeChiot.name.tr,
  };

  static const Map<String, String> giftIcons = {
    'rose': 'local_florist',
    'chocolat': 'cake',
    'bouquet': 'eco',
    'vetement': 'checkroom',
    'coeur': 'favorite',
    'bague': 'diamond',
    'papillon': 'flutter_dash',
    'trophee': 'emoji_events',
    'donut': 'donut_large',
    'pizza': 'local_pizza',
    'sac': 'shopping_bag',
    'chiot': 'pets',
  };

  static const List<String> regularGifts = [
    'rose',
    'chocolat',
    'bouquet',
    'vetement',
    'coeur',
    'bague',
  ];

  static const List<String> premiumGifts = [
    'papillon',
    'trophee',
    'donut',
    'pizza',
    'sac',
    'chiot',
  ];
}
