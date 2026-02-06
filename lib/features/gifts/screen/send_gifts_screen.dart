import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/features/activity/model/user_gift_model.dart';
import 'package:afriqueen/features/home/model/home_model.dart';
import 'package:afriqueen/features/gifts/service/gift_recharge_service.dart';
import 'package:afriqueen/features/gifts/service/gift_send_service.dart';
import 'package:afriqueen/services/premium_service.dart';

class SendGiftsScreen extends StatefulWidget {
  const SendGiftsScreen({super.key});

  @override
  State<SendGiftsScreen> createState() => _SendGiftsScreenState();
}

class _SendGiftsScreenState extends State<SendGiftsScreen> {
  HomeModel? recipientUser;
  final PremiumService _premiumService = PremiumService();
  bool _isUserPremium = false;

  @override
  void initState() {
    super.initState();
    // Get the recipient user from arguments
    final args = Get.arguments;
    print('SendGiftsScreen: Received arguments: $args');
    print('SendGiftsScreen: Arguments type: ${args.runtimeType}');
    
    if (args is HomeModel) {
      recipientUser = args;
      print('SendGiftsScreen: Recipient user set: ${recipientUser?.name} (ID: ${recipientUser?.id})');
    } else {
      print('SendGiftsScreen: Arguments is not HomeModel, type: ${args.runtimeType}');
      // Try to get arguments from Get.arguments again as a fallback
      if (Get.arguments != null) {
        print('SendGiftsScreen: Fallback - Get.arguments: ${Get.arguments}');
        print('SendGiftsScreen: Fallback - Get.arguments type: ${Get.arguments.runtimeType}');
      }
    }
    
    // Initialize recharge timers
    GiftRechargeService.initializeRechargeTimers();
    
    // Check user's premium status
    _checkUserPremiumStatus();
  }

  Future<void> _checkUserPremiumStatus() async {
    try {
      final isPremium = await _premiumService.isUserPremium();
      setState(() {
        _isUserPremium = isPremium;
      });
      print('SendGiftsScreen: User premium status: $_isUserPremium');
    } catch (e) {
      print('SendGiftsScreen: Error checking premium status: $e');
      setState(() {
        _isUserPremium = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          EnumLocale.sendGiftsTitle.name.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Regular Gifts Section
          Expanded(
            child: StreamBuilder<List<UserGiftModel>>(
              stream: _getUserGiftsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFF7BD8E)),
                  );
                }

                final gifts = snapshot.data ?? [];
                final regularGifts = gifts.where((gift) => !gift.isPremium).toList();
                final premiumGifts = gifts.where((gift) => gift.isPremium).toList();

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Regular Gifts
                      _buildGiftList(regularGifts, false),
                      
                      SizedBox(height: 24.h),
                      
                      // Premium Gifts Section
                      _buildPremiumGiftsHeader(),
                      SizedBox(height: 16.h),
                      _buildGiftList(premiumGifts, true),
                      
                      SizedBox(height: 120.h), // More space for bottom button
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Back Button
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  EnumLocale.sendGiftsBack.name.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumGiftsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40.w,
          height: 1.h,
          color: Colors.grey.shade300,
        ),
        SizedBox(width: 16.w),
        Icon(
          Icons.card_giftcard,
          size: 20.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Text(
          EnumLocale.giftCadeauxPremium.name.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        SizedBox(width: 16.w),
        Container(
          width: 40.w,
          height: 1.h,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildGiftList(List<UserGiftModel> gifts, bool isPremium) {
    return Column(
      children: gifts.map((gift) => _buildGiftCard(gift, isPremium)).toList(),
    );
  }

  Widget _buildGiftCard(UserGiftModel gift, bool isPremium) {
    // For premium gifts, check if user is premium AND has remaining count
    // For regular gifts, only check remaining count
    final canSend = isPremium 
        ? (_isUserPremium && gift.remainingCount > 0)
        : gift.remainingCount > 0;
    
    // Check if this is a premium gift that's locked due to non-premium status
    final isPremiumLocked = isPremium && !_isUserPremium;
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isPremiumLocked ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isPremiumLocked ? Colors.grey.shade300 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isPremiumLocked ? Colors.grey.shade200 : Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gift Icon
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              _getGiftIcon(gift.giftType),
              size: 32.sp,
              color: isPremiumLocked 
                  ? Colors.grey.shade400 
                  : (canSend ? _getGiftIconColor(gift.giftType) : Colors.grey.shade400),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Gift Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift Name
                Text(
                  GiftTypes.giftNames[gift.giftType] ?? gift.giftType,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isPremiumLocked 
                        ? Colors.grey.shade400 
                        : (canSend ? AppColors.black : Colors.grey.shade400),
                  ),
                ),
                
                SizedBox(height: 4.h),
                
                // Remaining Count or Premium Lock Message
                Text(
                  isPremiumLocked 
                      ? EnumLocale.giftPremiumRequired.name.tr
                      : '${gift.remainingCount} ${gift.remainingCount > 1 ? EnumLocale.giftRestants.name.tr : EnumLocale.giftRestant.name.tr}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isPremiumLocked 
                        ? Colors.red.shade400 
                        : (canSend ? Colors.grey.shade600 : Colors.grey.shade400),
                    fontWeight: isPremiumLocked ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Send Button
                SizedBox(
                  width: 100.w,
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: canSend && !isPremiumLocked ? () => _sendGift(gift) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (canSend && !isPremiumLocked) ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                      foregroundColor: (canSend && !isPremiumLocked) ? Colors.white : Colors.grey.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isPremiumLocked ? EnumLocale.giftLocked.name.tr : EnumLocale.sendGiftsSend.name.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Lock icon for premium gifts that are locked
                if (isPremiumLocked) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 16.sp,
                        color: Colors.red.shade400,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Premium',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Recharge Info
          Expanded(
            child: FutureBuilder<Duration?>(
              future: GiftRechargeService.getTimeUntilNextRecharge(gift.giftType),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final timeUntilRecharge = snapshot.data!;
                  if (timeUntilRecharge == Duration.zero) {
                    return Text(
                      EnumLocale.rechargeReady.name.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    );
                  } else {
                    return Text(
                      '${EnumLocale.rechargeNextIn.name.tr} ${GiftRechargeService.formatDuration(timeUntilRecharge)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.right,
                    );
                  }
                }
                return Text(
                  _getRechargeText(gift.giftType),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getRechargeText(String giftType) {
    switch (giftType) {
      case 'rose':
        return EnumLocale.rechargeRose.name.tr;
      case 'chocolat':
        return EnumLocale.rechargeChocolat.name.tr;
      case 'bouquet':
        return EnumLocale.rechargeBouquet.name.tr;
      case 'vetement':
        return EnumLocale.rechargeVetement.name.tr;
      case 'coeur':
        return EnumLocale.rechargeCoeur.name.tr;
      case 'bague':
        return EnumLocale.rechargeBague.name.tr;
      case 'papillon':
        return EnumLocale.rechargePapillon.name.tr;
      case 'trophee':
        return EnumLocale.rechargeTrophee.name.tr;
      case 'donut':
        return EnumLocale.rechargeDonut.name.tr;
      case 'pizza':
        return EnumLocale.rechargePizza.name.tr;
      case 'sac':
        return EnumLocale.rechargeSac.name.tr;
      case 'chiot':
        return EnumLocale.rechargeChiot.name.tr;
      default:
        return 'Vos cadeaux se rechargeront dans 24h.'; // Fallback
    }
  }

  IconData _getGiftIcon(String giftType) {
    final iconName = GiftTypes.giftIcons[giftType] ?? 'card_giftcard';
    
    switch (iconName) {
      case 'local_florist':
        return Icons.local_florist;
      case 'cake':
        return Icons.cake;
      case 'eco':
        return Icons.eco;
      case 'checkroom':
        return Icons.checkroom;
      case 'favorite':
        return Icons.favorite;
      case 'diamond':
        return Icons.diamond;
      case 'flutter_dash':
        return Icons.flutter_dash;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'donut_large':
        return Icons.donut_large;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'pets':
        return Icons.pets;
      default:
        return Icons.card_giftcard;
    }
  }

  Color _getGiftIconColor(String giftType) {
    switch (giftType) {
      case 'rose':
        return Colors.pink;
      case 'chocolat':
        return Colors.brown;
      case 'bouquet':
        return Colors.green;
      case 'vetement':
        return Colors.blue;
      case 'coeur':
        return Colors.red;
      case 'bague':
        return Colors.purple;
      case 'papillon':
        return Colors.orange;
      case 'trophee':
        return Colors.amber;
      case 'donut':
        return Colors.brown;
      case 'pizza':
        return Colors.red;
      case 'sac':
        return Colors.grey;
      case 'chiot':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Stream<List<UserGiftModel>> _getUserGiftsStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) {
      // Always start with default gifts (all with 0 count)
      final defaultGifts = _getDefaultGiftsWithZeroCount();
      
      if (snapshot.docs.isEmpty) {
        // Return default gifts with 0 count if collection doesn't exist
        return defaultGifts;
      }
      
      // Merge Firestore data with default gifts
      final firestoreGifts = snapshot.docs.map((doc) => UserGiftModel.fromFirestore(doc)).toList();
      final Map<String, UserGiftModel> giftMap = {};
      
      // Add default gifts first (all with 0 count)
      for (var gift in defaultGifts) {
        giftMap[gift.giftType] = gift;
      }
      
      // Update with Firestore data
      for (var gift in firestoreGifts) {
        giftMap[gift.giftType] = gift;
      }
      
      return giftMap.values.toList();
    }).handleError((error) {
      // If there's any error (like permission denied), return default gifts with 0 count
      return _getDefaultGiftsWithZeroCount();
    });
  }

  List<UserGiftModel> _getDefaultGiftsWithZeroCount() {
    final List<UserGiftModel> defaultGifts = [];
    
    // Add regular gifts with 0 count
    for (String giftType in GiftTypes.regularGifts) {
      defaultGifts.add(UserGiftModel(
        giftType: giftType,
        remainingCount: 0,
        isPremium: false,
      ));
    }
    
    // Add premium gifts with 0 count
    for (String giftType in GiftTypes.premiumGifts) {
      defaultGifts.add(UserGiftModel(
        giftType: giftType,
        remainingCount: 0,
        isPremium: true,
      ));
    }
    
    return defaultGifts;
  }

  void _sendGift(UserGiftModel gift) async {
    print('SendGiftsScreen: _sendGift called for gift: ${gift.giftType}');
    print('SendGiftsScreen: recipientUser is null: ${recipientUser == null}');
    if (recipientUser != null) {
      print('SendGiftsScreen: recipientUser name: ${recipientUser!.name}, ID: ${recipientUser!.id}');
    }
    
    // Check if this is a premium gift and user is not premium
    if (gift.isPremium && !_isUserPremium) {
      print('SendGiftsScreen: Attempted to send premium gift without premium status');
      Get.snackbar(
        EnumLocale.giftPremiumRequired.name.tr,
        EnumLocale.giftPremiumRequiredMessage.name.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    // Try to get recipient user from arguments again if null
    if (recipientUser == null) {
      print('SendGiftsScreen: recipientUser is null, trying to get from arguments again');
      final args = Get.arguments;
      print('SendGiftsScreen: Re-checking arguments: $args');
      if (args is HomeModel) {
        recipientUser = args;
        print('SendGiftsScreen: Recipient user recovered: ${recipientUser?.name} (ID: ${recipientUser?.id})');
      }
    }
    
    if (recipientUser == null) {
      print('SendGiftsScreen: recipientUser is still null, showing error');
      Get.snackbar(
        EnumLocale.sendGiftsError.name.tr,
        EnumLocale.sendGiftsUserNotFound.name.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if user has the gift available
    print('SendGiftsScreen: Checking if user has gift available...');
    final hasGift = await GiftRechargeService.hasGiftAvailable(gift.giftType);
    print('SendGiftsScreen: Has gift available: $hasGift');
    
    if (!hasGift) {
      print('SendGiftsScreen: User does not have gift available, showing error');
      Get.snackbar(
        EnumLocale.sendGiftsError.name.tr,
        EnumLocale.sendGiftError.name.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Send gift using the gift send service
    print('SendGiftsScreen: About to call GiftSendService.sendGift...');
    final success = await GiftSendService.sendGift(
      recipientId: recipientUser!.id,
      giftType: gift.giftType,
      giftName: GiftTypes.giftNames[gift.giftType] ?? gift.giftType,
    );
    print('SendGiftsScreen: GiftSendService.sendGift returned: $success');
    
    if (success) {
      Get.snackbar(
        EnumLocale.sendGiftsGiftSent.name.tr,
        '${GiftTypes.giftNames[gift.giftType]} ${EnumLocale.sendGiftsGiftSentTo.name.tr} ${recipientUser!.name}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        EnumLocale.sendGiftsError.name.tr,
        EnumLocale.sendGiftError.name.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
