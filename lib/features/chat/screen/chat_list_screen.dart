import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/model/message_request_model.dart';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/widget/chat_list_item.dart';
import 'package:afriqueen/features/chat/widget/message_request_item.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:afriqueen/features/chat/screen/message_requests_screen.dart';
import 'package:afriqueen/features/chat/screen/chat_screen.dart';
import 'package:afriqueen/features/event/bloc/event_message_bloc.dart';
import 'package:afriqueen/features/event/model/event_message_model.dart';
import 'package:afriqueen/features/event/repository/event_message_repository.dart';
import 'package:afriqueen/features/event/widget/event_message_item.dart';
import 'package:afriqueen/features/event/repository/event_request_repository.dart';
import 'package:afriqueen/features/event/model/event_request_model.dart';
import 'package:afriqueen/features/event/repository/event_repository.dart';
import 'package:afriqueen/services/distance/distance_calculator.dart';
import 'package:afriqueen/routes/app_routes.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with TickerProviderStateMixin {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  late TabController _topTabController;
  late TabController _bottomTabController;
  
  int _selectedTopTabIndex = 0;
  int _selectedBottomTabIndex = 0;
  int _selectedStatusIndex = 3; // Toutes selected by default for Demande tab
  
  final EventRequestRepository _eventRequestRepository = EventRequestRepository();
  final EventRepository _eventRepository = EventRepository();

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: 5, vsync: this);
    _bottomTabController = TabController(length: 2, vsync: this);
    
    // Set up French locale for timeago
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    
    // Load chats by default (Message tab)
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  void dispose() {
    _topTabController.dispose();
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getBreadcrumbText(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                  color: AppColors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () {
                // Filter functionality
              },
              icon: Icon(
                Icons.tune_outlined,
                size: 22.r,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        leading: Container(
          margin: EdgeInsets.only(left: 8.w),
          child: IconButton(
            icon: Icon(
              Icons.home_outlined,
              color: AppColors.black,
              size: 24.sp,
            ),
            onPressed: () => Get.toNamed(AppRoutes.profileHome),
          ),
        ),
      ),
      body: Column(
        children: [
          // Top Navigation Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              children: [
                // First row of tabs
                Container(
                  height: 32.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildTopTab(EnumLocale.chatMessage.name.tr, 0, _selectedTopTabIndex == 0, 0),
                      _buildTopTab(EnumLocale.chatDemande.name.tr, 1, _selectedTopTabIndex == 1, 0),
                      _buildTopTab(EnumLocale.chatEvent.name.tr, 2, _selectedTopTabIndex == 2, 0),
                      _buildTopTab(EnumLocale.chatArchiv.name.tr, 3, _selectedTopTabIndex == 3, 0),
                    ],
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                // Second row of tabs - show different tabs based on selected top tab
                if (_selectedTopTabIndex == 1) ...[
                  // Demande tab
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBottomTab(EnumLocale.chatDemandesRecus.name.tr, 0, _selectedBottomTabIndex == 0),
                        _buildBottomTab(EnumLocale.chatDemandesFaites.name.tr, 1, _selectedBottomTabIndex == 1),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  // Third row of tabs - only show for Demande tab
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatusTab(EnumLocale.chatEnAttente.name.tr, 0, _selectedStatusIndex == 0),
                        _buildStatusTab(EnumLocale.chatAcceptees.name.tr, 1, _selectedStatusIndex == 1),
                        _buildStatusTab(EnumLocale.chatRefusees.name.tr, 2, _selectedStatusIndex == 2),
                        _buildStatusTab(EnumLocale.chatToutes.name.tr, 3, _selectedStatusIndex == 3),
                      ],
                    ),
                  ),
                  
                ] else if (_selectedTopTabIndex == 2) ...[
                  // Event tab - match the image design
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildEventBottomTab(EnumLocale.eventIlsOntParticipe.name.tr, 0, _selectedBottomTabIndex == 0),
                        _buildEventBottomTab(EnumLocale.eventJaiParticipe.name.tr, 1, _selectedBottomTabIndex == 1),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 6.h),
                  
                  // Second row for event tabs
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildEventBottomTab(EnumLocale.eventTous.name.tr, 2, _selectedBottomTabIndex == 2),
                        _buildEventBottomTab(EnumLocale.eventNonLu.name.tr, 3, _selectedBottomTabIndex == 3),
                      ],
                    ),
                  ),
                  
                ] else ...[
                  // Other tabs (Message, Notif, Archive)
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBottomTab(EnumLocale.chatTous.name.tr, 0, _selectedBottomTabIndex == 0),
                        _buildBottomTab(EnumLocale.chatNonLu.name.tr, 2, _selectedBottomTabIndex == 2),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Event tab button
          if (_selectedTopTabIndex == 2) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<EventMessageBloc>().add(DeleteFinishedEventDiscussions());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91E63), // Pink color matching the image
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r), // More rounded corners
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    elevation: 0, // Remove shadow
                  ),
                 child: Text(
                   EnumLocale.eventSupprimerDiscussions.name.tr,
                   style: TextStyle(
                     fontSize: 15.sp,
                     fontWeight: FontWeight.w600,
                     color: Colors.white,
                   ),
                   textAlign: TextAlign.center,
                 ),
                ),
              ),
            ),
          ],
          
          // Archive tab button
          if (_selectedTopTabIndex == 3) ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 160.w, // Even smaller width
                  margin: EdgeInsets.only(left: 16.w), // Align with main container padding
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement delete archive history
                      print('Delete archive history');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF8BBD9), // Soft light pink background like in image
                      foregroundColor: Color(0xFFE91E63), // Darker pink text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.r), // Very rounded corners like pill shape
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // Even smaller padding
                      elevation: 0, // Remove shadow
                      minimumSize: Size(160.w, 32.h), // Even smaller fixed size
                    ),
                    child: Text(
                      EnumLocale.archiveSupprimerHistorique.name.tr,
                      style: TextStyle(
                        fontSize: 11.sp, // Even smaller font size
                        fontWeight: FontWeight.w500, // Medium weight
                        color: Color(0xFFE91E63), // Darker pink text
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
          
          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  String _getBreadcrumbText() {
    String topTab = '';
    String bottomTab = '';
    
    // Get top tab name
    switch (_selectedTopTabIndex) {
      case 0:
        topTab = EnumLocale.topTabMessage.name.tr;
        break;
      case 1:
        topTab = EnumLocale.topTabDemande.name.tr;
        break;
      case 2:
        topTab = EnumLocale.topTabEvent.name.tr;
        break;
      case 3:
        topTab = EnumLocale.topTabArchive.name.tr;
        break;
      case 4:
        topTab = EnumLocale.topTabNotif.name.tr;
        break;
    }
    
    // Get bottom tab name based on top tab
    if (_selectedTopTabIndex == 1) {
      // Demande tab
      switch (_selectedBottomTabIndex) {
        case 0:
          bottomTab = EnumLocale.demandeRecus.name.tr;
          break;
        case 1:
          bottomTab = EnumLocale.demandeFaites.name.tr;
          break;
      }
      
      // Get status tab name
      String statusTab = '';
      switch (_selectedStatusIndex) {
        case 0:
          statusTab = EnumLocale.demandeEnAttente.name.tr;
          break;
        case 1:
          statusTab = EnumLocale.demandeAcceptees.name.tr;
          break;
        case 2:
          statusTab = EnumLocale.demandeRefusees.name.tr;
          break;
        case 3:
          statusTab = EnumLocale.demandeToutes.name.tr;
          break;
      }
      
      return '${EnumLocale.messagerie.name.tr}/Demande/$bottomTab/$statusTab';
    } else if (_selectedTopTabIndex == 2) {
      // Event tab
      switch (_selectedBottomTabIndex) {
        case 0:
          bottomTab = EnumLocale.eventIlsOntParticipe.name.tr;
          break;
        case 1:
          bottomTab = EnumLocale.eventJaiParticipe.name.tr;
          break;
        case 2:
          bottomTab = EnumLocale.eventTous.name.tr;
          break;
        case 3:
          bottomTab = EnumLocale.eventNonLu.name.tr;
          break;
      }
      
      return '${EnumLocale.messagerie.name.tr}/Event/$bottomTab';
    } else {
      // Other tabs (Message, Notif, Archive)
      switch (_selectedBottomTabIndex) {
        case 0:
          bottomTab = EnumLocale.eventTous.name.tr;
          break;
        case 2:
          bottomTab = EnumLocale.eventNonLu.name.tr;
          break;
      }
      
      return '${EnumLocale.messagerie.name.tr}/$topTab/$bottomTab';
    }
  }

  Widget _buildTopTab(String title, int index, bool isSelected, int count) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedTopTabIndex = index;
              // Reset bottom tab and status index when top tab changes
              _selectedBottomTabIndex = 0;
              _selectedStatusIndex = index == 1 ? 3 : 0;
            });
            
            print('DEBUG: Top tab tapped - index: $index, selectedTopTabIndex: $_selectedTopTabIndex');
            print('DEBUG: Bottom tab reset to: $_selectedBottomTabIndex');
            print('DEBUG: Status index reset to: $_selectedStatusIndex');
            
            // Load appropriate data based on selected tab
            if (index == 0) {
              // Message tab - load chats
              print('DEBUG: Loading regular chats');
              context.read<ChatBloc>().add(LoadChats());
            } else if (index == 1) {
              // Demande tab - load received requests by default
              print('DEBUG: Loading received request chats');
              context.read<ChatBloc>().add(LoadReceivedRequestChats());
            } else if (index == 2) {
              // Event tab - load event messages
              print('DEBUG: Loading event messages');
              context.read<EventMessageBloc>().add(LoadUserEventMessages());
            } else if (index == 3) {
              // Archive tab - load archived chats
              print('DEBUG: Loading archived chats');
              context.read<ChatBloc>().add(LoadArchivedChats());
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedTopTabIndex == index ? Color(0xFFF7BD8E) : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _selectedTopTabIndex == index ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 12.sp,
                    fontWeight: _selectedTopTabIndex == index ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 4.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(String title, int count, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 85.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedBottomTabIndex = count;
            });
            
            print('DEBUG: Bottom tab tapped - count: $count, selectedBottomTabIndex: $_selectedBottomTabIndex');
            print('DEBUG: Selected top tab: $_selectedTopTabIndex');
            
            // Load appropriate data based on selected bottom tab
            if (_selectedTopTabIndex == 1) { // Demande tab
              if (count == 0) {
                // "Demandes reçus" tab
                print('DEBUG: Loading received request chats');
                context.read<ChatBloc>().add(LoadReceivedRequestChats());
              } else if (count == 1) {
                // "Demandes faites" tab
                print('DEBUG: Loading sent request chats');
                context.read<ChatBloc>().add(LoadSentRequestChats());
              }
            } else if (_selectedTopTabIndex == 2) { // Event tab
              // Reload event messages with different filters
              print('DEBUG: Reloading event messages with filter: $count');
              context.read<EventMessageBloc>().add(LoadUserEventMessages());
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedBottomTabIndex == count ? Color(0xFFF7BD8E) : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _selectedBottomTabIndex == count ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: _selectedBottomTabIndex == count ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventBottomTab(String title, int count, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedBottomTabIndex = count;
            });
            
            print('DEBUG: Event bottom tab tapped - count: $count, selectedBottomTabIndex: $_selectedBottomTabIndex');
            
            // Reload event messages with different filters
            context.read<EventMessageBloc>().add(LoadUserEventMessages());
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedBottomTabIndex == count ? Color(0xFFF7BD8E) : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _selectedBottomTabIndex == count ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: _selectedBottomTabIndex == count ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTab(String title, int count, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right:14.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedStatusIndex = count;
            });
            
            print('DEBUG: Status tab tapped - count: $count, selectedStatusIndex: $_selectedStatusIndex');
            print('DEBUG: Selected top tab: $_selectedTopTabIndex');
            print('DEBUG: Selected bottom tab: $_selectedBottomTabIndex');
            
            // Reload data when status changes
            if (_selectedTopTabIndex == 1) {
              if (_selectedBottomTabIndex == 0) {
                // "Demandes reçus" tab
                print('DEBUG: Reloading received request chats');
                context.read<ChatBloc>().add(LoadReceivedRequestChats());
              } else if (_selectedBottomTabIndex == 1) {
                // "Demandes faites" tab
                print('DEBUG: Reloading sent request chats');
                context.read<ChatBloc>().add(LoadSentRequestChats());
              }
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _selectedStatusIndex == count ? Color(0xFFF7BD8E) : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _selectedStatusIndex == count ? Color(0xFFF7BD8E) : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: _selectedStatusIndex == count ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatModel> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFF7BD8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64.sp,
                color: Color(0xFFF7BD8E),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              EnumLocale.noMessagesOrRequests.name.tr,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              EnumLocale.chatStartConversation.name.tr,
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatListItem(chat: chat);
      },
    );
  }

  Widget _buildRequestItem(ChatModel chat) {
    // Get participant info (the other user)
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    if (chat.participants.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFF7BD8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 64.sp,
                color: Color(0xFFF7BD8E),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              EnumLocale.noDataAvailable.name.tr,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    final participantInfo = chat.participants
        .firstWhere((participant) => participant['id'] != currentUserId, 
                   orElse: () => chat.participants.isNotEmpty ? chat.participants.first : <String, dynamic>{});
    
    // Get status text and color
    String statusText = '';
    Color statusColor = Colors.grey;
    String timeAgo = '';
    
    if (chat.lastMessageTime != null) {
      timeAgo = timeago.format(chat.lastMessageTime!, locale: 'fr');
    } else {
      timeAgo = 'recently';
    }
    
    switch (chat.status) {
      case 'ACCEPTED':
        statusText = 'Accepté il y a $timeAgo';
        statusColor = Colors.grey.shade600;
        break;
      case 'REJECTED':
      case 'DECLINED':
        statusText = 'Refusé il y a $timeAgo';
        statusColor = Colors.red;
        break;
      case 'PENDING':
      default:
        statusText = 'Reçu il y a $timeAgo';
        statusColor = Colors.orange;
        break;
    }
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              image: participantInfo['photoUrl'] != null && participantInfo['photoUrl'].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(participantInfo['photoUrl']!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: participantInfo['photoUrl'] == null || participantInfo['photoUrl'].isEmpty
                ? Icon(
                    Icons.person,
                    size: 22.sp,
                    color: Colors.grey.shade600,
                  )
                : null,
          ),
          
          SizedBox(width: 8.w),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  (participantInfo['name']?.toString().trim().isNotEmpty == true
                      ? participantInfo['name']!.toString().trim()
                      : (participantInfo['pseudo']?.toString().trim().isNotEmpty == true
                          ? participantInfo['pseudo']!.toString().trim()
                          : EnumLocale.unknownUser.name.tr)),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4.h),
                
                // Status and Time
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4.h),
                
                // Age, Distance, and Marital Status
                FutureBuilder<double?>(
                  future: DistanceCalculator.calculateDistanceToUser(
                    participantInfo['city']?.toString() ?? '',
                    participantInfo['country']?.toString() ?? '',
                  ),
                  builder: (context, snapshot) {
                    final distance = snapshot.data;
                    final distanceText = DistanceCalculator.formatDistance(distance);
                    return Text(
                      '${participantInfo['age'] ?? 'N/A'} ans • $distanceText • ${participantInfo['maritalStatus'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                
                SizedBox(height: 6.h),
                
                // Bio snippet
                Text(
                  participantInfo['description'] ?? 'No bio available',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                  ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                ),
                
                // Bottom actions row (status + action button)
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Status text on the left
                    Expanded(
                      child: Row(
                        children: [
                          if (chat.status == 'ACCEPTED') ...[
                            Icon(
                              Icons.check_circle_outline,
                              size: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                            SizedBox(width: 2.w),
                          ],
                          Expanded(
                            child: Text(
                              chat.status == 'ACCEPTED'
                                  ? EnumLocale.chatAccepted.name.tr
                                  : chat.status == 'REJECTED' || chat.status == 'DECLINED'
                                      ? EnumLocale.chatRejected.name.tr
                                      : EnumLocale.chatPending.name.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action button on the right
                    if (chat.status == null || chat.status == 'PENDING') ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 32.h,
                        child: ElevatedButton(
                          onPressed: () {
                            final otherUserId = participantInfo['id'];
                            context.read<ChatBloc>().add(DeclineRequestChat(chatId: chat.id, otherUserId: otherUserId));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ] else if (chat.status == 'ACCEPTED') ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 30.h,
                        child: ElevatedButton(
                          onPressed: () {
                            if (chat.participants.isEmpty) {
                              return;
                            }
                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            final otherUser = chat.participants.firstWhere(
                              (u) => u['id'] != currentUserId,
                              orElse: () => chat.participants.isNotEmpty ? chat.participants.first : <String, dynamic>{},
                            );
                            if (otherUser.isEmpty || otherUser['id'] == null) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RepositoryProvider(
                                  create: (context) => ChatRepository(),
                                  child: BlocProvider(
                                    create: (context) => ChatBloc(ChatRepository()),
                                    child: ChatScreen(
                                      chatId: chat.id,
                                      receiverId: otherUser['id'],
                                      receiverName: otherUser['name'],
                                      receiverPhotoUrl: otherUser['photoUrl'],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 12.sp),
                              SizedBox(width: 4.w),
                              Text(
                                EnumLocale.chatMessage.name.tr,
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (chat.status == 'REJECTED' || chat.status == 'DECLINED') ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 32.h,
                        child: ElevatedButton(
                          onPressed: () {
                            final otherUserId = participantInfo['id'];
                            context.read<ChatBloc>().add(ArchiveRejectedProfile(otherUserId));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline, size: 12.sp, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text(
                                'Archiver profil',
                                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(width: 4.w),
          
          // Action Buttons (moved inside main column to match UI and avoid overflow)
          SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildFilteredRequestChats(List<ChatModel> requestChats) {
    // Filter chats based on selected status
    List<ChatModel> filteredChats = [];
    
    // First, ensure we only work with actual request chats
    final validRequestChats = requestChats.where((chat) => chat.isRequest == true).toList();
    
    // Debug: Print what we received and filtered
    print('DEBUG: Total requestChats received: ${requestChats.length}');
    print('DEBUG: Valid request chats (isRequest: true): ${validRequestChats.length}');
    print('DEBUG: Selected status index: $_selectedStatusIndex');
    
    switch (_selectedStatusIndex) {
      case 0: // En attente
        filteredChats = validRequestChats.where((chat) => 
          chat.status == 'PENDING' || chat.status == null).toList();
        print('DEBUG: PENDING chats found: ${filteredChats.length}');
        for (var chat in filteredChats) {
          print('DEBUG: PENDING chat ${chat.id} - status: ${chat.status}, isRequest: ${chat.isRequest}');
        }
        break;
      case 1: // Acceptées
        filteredChats = validRequestChats.where((chat) => 
          chat.status == 'ACCEPTED').toList();
        print('DEBUG: ACCEPTED chats found: ${filteredChats.length}');
        for (var chat in filteredChats) {
          print('DEBUG: ACCEPTED chat ${chat.id} - status: ${chat.status}, isRequest: ${chat.isRequest}');
        }
        break;
      case 2: // Refusées
        filteredChats = validRequestChats.where((chat) => 
          chat.status == 'REJECTED' || chat.status == 'DECLINED').toList();
        print('DEBUG: REJECTED chats found: ${filteredChats.length}');
        for (var chat in filteredChats) {
          print('DEBUG: REJECTED chat ${chat.id} - status: ${chat.status}, isRequest: ${chat.isRequest}');
        }
        break;
      case 3: // Toutes
      default:
        filteredChats = validRequestChats;
        print('DEBUG: ALL chats found: ${filteredChats.length}');
        for (var chat in filteredChats) {
          print('DEBUG: ALL chat ${chat.id} - status: ${chat.status}, isRequest: ${chat.isRequest}');
        }
        break;
    }

    // Debug: Print final filtered results
    print('DEBUG: Final filtered chats: ${filteredChats.length}');
    for (var chat in filteredChats) {
      print('DEBUG: Chat ${chat.id} - isRequest: ${chat.isRequest}, status: ${chat.status}');
    }

    if (filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFF7BD8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64.sp,
                color: Color(0xFFF7BD8E),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              EnumLocale.chatNoRequestsFound.name.tr,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              EnumLocale.chatNoRequestsMatchCriteria.name.tr,
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return _buildRequestItem(chat);
      },
    );
  }

  Widget _buildRequestsList(List<MessageRequestModel> receivedRequests, List<ChatModel> requestChats) {
    if (receivedRequests.isEmpty && requestChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFF7BD8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64.sp,
                color: Color(0xFFF7BD8E),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              EnumLocale.noMessagesOrRequests.name.tr,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'No message requests yet. Start a conversation with someone!',
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
      itemCount: receivedRequests.length + requestChats.length,
      itemBuilder: (context, index) {
        if (index < receivedRequests.length) {
          return MessageRequestItem(request: receivedRequests[index]);
        } else {
          return ChatListItem(chat: requestChats[index - receivedRequests.length]);
        }
      },
    );
  }

  Widget _buildContent() {
    if (_selectedTopTabIndex == 0) {
      // Message tab - show all chats
      return BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          try {
            if (state is ChatLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF7BD8E),
                strokeWidth: 3.w,
              ),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Color(0xFFF7BD8E),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ChatListLoaded) {
            if (state.chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7BD8E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 64.sp,
                        color: Color(0xFFF7BD8E),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'No chats yet',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start a conversation with someone',
                      style: TextStyle(
                        color: AppColors.grey.withOpacity(0.7),
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                return ChatListItem(chat: state.chats[index]);
              },
            );
          }

          return const SizedBox.shrink();
          } catch (e) {
            // Catch any "Bad state: No element" or other errors
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFF7BD8E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 64.sp,
                      color: Color(0xFFF7BD8E),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    EnumLocale.noDataAvailable.name.tr,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else if (_selectedTopTabIndex == 1) {
      // Demande tab - show message requests based on selected tabs
      return BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          try {
            // Debug: Print current state
            print('DEBUG: Demande tab - Current state: ${state.runtimeType}');
            print('DEBUG: Selected bottom tab: $_selectedBottomTabIndex');
            print('DEBUG: Selected status tab: $_selectedStatusIndex');
            
            if (state is ChatLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFF7BD8E),
                  strokeWidth: 3.w,
                ),
              );
            }

            if (state is ChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Color(0xFFF7BD8E),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // Handle different states based on selected tabs
            if (_selectedBottomTabIndex == 0) {
              // "Demandes reçus" tab
              if (state is ReceivedRequestChatsLoaded) {
                print('DEBUG: ReceivedRequestChatsLoaded with ${state.receivedRequestChats.length} chats');
                return _buildFilteredRequestChats(state.receivedRequestChats);
              }
            } else if (_selectedBottomTabIndex == 1) {
              // "Demandes faites" tab
              if (state is SentRequestChatsLoaded) {
                print('DEBUG: SentRequestChatsLoaded with ${state.sentRequestChats.length} chats');
                return _buildFilteredRequestChats(state.sentRequestChats);
              }
            }

            // Fallback states
            if (state is MessageRequestsLoaded) {
              print('DEBUG: MessageRequestsLoaded with ${state.requests.length} requests');
              return _buildRequestsList(state.requests, []);
            }

            if (state is RequestChatsLoaded) {
              print('DEBUG: RequestChatsLoaded with ${state.requestChats.length} request chats');
              return _buildRequestsList([], state.requestChats);
            }

            if (state is RequestsAndRequestChatsLoaded) {
              print('DEBUG: RequestsAndRequestChatsLoaded with ${state.requests.length} requests and ${state.requestChats.length} request chats');
              return _buildRequestsList(state.requests, state.requestChats);
            }

            if (state is ChatListWithRequestsLoaded) {
              print('DEBUG: ChatListWithRequestsLoaded with ${state.requests.length} requests');
              return _buildRequestsList(state.requests, []);
            }

            // If no specific state is matched, show loading
            print('DEBUG: No specific state matched, showing loading');
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF7BD8E),
                strokeWidth: 3.w,
              ),
            );
          } catch (e) {
            // Catch any "Bad state: No element" or other errors
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFF7BD8E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 64.sp,
                      color: Color(0xFFF7BD8E),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    EnumLocale.noDataAvailable.name.tr,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    } else if (_selectedTopTabIndex == 2) {
      // Event tab - show event participation requests
      return _buildEventParticipationContent();
    } else if (_selectedTopTabIndex == 3) {
      // Archive tab - show archived chats
      return BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF7BD8E),
                strokeWidth: 3.w,
              ),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Color(0xFFF7BD8E),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is ChatListLoaded) {
            // All chats from getArchivedChatsStream are already filtered as archived
            final archivedChats = state.chats;
            
            if (archivedChats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Color(0xFFF7BD8E).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.archive_outlined,
                        size: 64.sp,
                        color: Color(0xFFF7BD8E),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      EnumLocale.archiveAucunChatArchive.name.tr,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      EnumLocale.archiveConversationsArchiveesApparaitront.name.tr,
                      style: TextStyle(
                        color: AppColors.grey.withOpacity(0.7),
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
              itemCount: archivedChats.length,
              itemBuilder: (context, index) {
                return ChatListItem(chat: archivedChats[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      );
    } else {
      // Other tabs - show placeholder
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Color(0xFFF7BD8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction_outlined,
                size: 64.sp,
                color: Color(0xFFF7BD8E),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              EnumLocale.archiveComingSoon.name.tr,
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              EnumLocale.archiveFeatureUnderDevelopment.name.tr,
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.7),
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  // Build event participation content based on selected bottom tab
  Widget _buildEventParticipationContent() {
    if (currentUserId == null) {
      return Center(
        child: Text(
          'Please log in to see event requests',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
        ),
      );
    }

    switch (_selectedBottomTabIndex) {
      case 0: // "Ils ont participé" (They participated)
        return _buildTheyParticipatedContent();
      case 1: // "J'ai participé" (I participated)
        return _buildIParticipatedContent();
      case 2: // "Tous" (All)
        return _buildAllEventRequestsContent();
      case 3: // "Non lu" (Unread)
        return _buildUnreadEventRequestsContent();
      default:
        return _buildTheyParticipatedContent();
    }
  }

  // They participated content - shows received event requests
  Widget _buildTheyParticipatedContent() {
    return StreamBuilder<List<EventRequestModel>>(
      stream: _eventRequestRepository.streamReceivedEventRequests(currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF7BD8E),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading event requests: ${snapshot.error}',
              style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 64.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No event participation requests yet',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildEventRequestCard(request);
          },
        );
      },
    );
  }

  // I participated content - shows sent event requests
  Widget _buildIParticipatedContent() {
    return StreamBuilder<List<EventRequestModel>>(
      stream: _eventRequestRepository.streamSentEventRequests(currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF7BD8E),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading your event requests: ${snapshot.error}',
              style: TextStyle(fontSize: 16.sp, color: Colors.red.shade600),
            ),
          );
        }

        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 64.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No event participation requests sent yet',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildMyEventRequestCard(request);
          },
        );
      },
    );
  }

  // All event requests content
  Widget _buildAllEventRequestsContent() {
    return Center(
      child: Text(
        'All event requests - Coming soon',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
      ),
    );
  }

  // Unread event requests content
  Widget _buildUnreadEventRequestsContent() {
    return Center(
      child: Text(
        'Unread event requests - Coming soon',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
      ),
    );
  }

  // Event request card for received requests (they participated)
  Widget _buildEventRequestCard(EventRequestModel request) {
    final timeAgo = timeago.format(request.createdAt, locale: 'en');
    String statusText = '';
    Color statusColor = Colors.grey.shade600;
    
    switch (request.status) {
      case EventRequestStatus.PENDING:
        statusText = '';
        break;
      case EventRequestStatus.ACCEPTED:
        statusText = 'Accepted';
        statusColor = Color(0xFF1DB954);
        break;
      case EventRequestStatus.REJECTED:
        statusText = 'Rejected';
        statusColor = Color(0xFFE53935);
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 48.w,
              height: 48.w,
              color: Colors.grey.shade300,
              child: (request.requesterPhotoUrl?.isNotEmpty == true)
                  ? Image.network(request.requesterPhotoUrl!, fit: BoxFit.cover)
                  : Icon(Icons.person, color: Colors.grey.shade600, size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.requesterName ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$timeAgo',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Event: ${request.eventTitle ?? 'Unknown Event'}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 10.h),
                // Show action buttons only for pending requests
                if (request.status == EventRequestStatus.PENDING)
                  Row(
                    children: [
                      _buildPillButton(
                        label: EnumLocale.accept.name.tr,
                        color: Color(0xFF1DB954),
                        onTap: () => _acceptEventRequest(request),
                      ),
                      SizedBox(width: 12.w),
                      _buildPillButton(
                        label: EnumLocale.reject.name.tr,
                        color: Color(0xFFE53935),
                        onTap: () => _rejectEventRequest(request),
                      ),
                    ],
                  )
                else
                  // Show status text for accepted/rejected requests
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Event request card for sent requests (I participated)
  Widget _buildMyEventRequestCard(EventRequestModel request) {
    final timeAgo = timeago.format(request.createdAt, locale: 'en');
    String statusText = '';
    Color statusColor = Colors.grey.shade600;
    
    switch (request.status) {
      case EventRequestStatus.PENDING:
        statusText = EnumLocale.giftWaiting.name.tr;
        statusColor = Colors.orange;
        break;
      case EventRequestStatus.ACCEPTED:
        statusText = 'Accepted';
        statusColor = Color(0xFF1DB954);
        break;
      case EventRequestStatus.REJECTED:
        statusText = 'Rejected';
        statusColor = Color(0xFFE53935);
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 48.w,
              height: 48.w,
              color: Colors.grey.shade300,
              child: Icon(Icons.event, color: Colors.grey.shade600, size: 24.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.eventTitle ?? 'Unknown Event',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$timeAgo',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 2.h),
                Text(
                  request.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (request.status == EventRequestStatus.PENDING)
                      _buildPillButton(
                        label: EnumLocale.giftCancel.name.tr,
                        color: Color(0xFFF48B8B),
                        onTap: () => _cancelEventRequest(request),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pill button widget
  Widget _buildPillButton({required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        minimumSize: Size(80.w, 32.h),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Event request action methods
  Future<void> _acceptEventRequest(EventRequestModel request) async {
    try {
      // Update the request status to accepted
      await _eventRequestRepository.updateEventRequestStatus(
        requestId: request.id,
        status: EventRequestStatus.ACCEPTED,
      );
      
      // Add the user to the event's participants collection
      await _eventRepository.addParticipantToEvent(
        eventId: request.eventId,
        userId: request.requesterId,
        userName: request.requesterName,
        userPhotoUrl: request.requesterPhotoUrl,
      );
      
      Get.snackbar(
        'Success',
        'Event request accepted and user added to participants',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _rejectEventRequest(EventRequestModel request) async {
    try {
      await _eventRequestRepository.updateEventRequestStatus(
        requestId: request.id,
        status: EventRequestStatus.REJECTED,
      );
      
      Get.snackbar(
        'Success',
        'Event request rejected',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _cancelEventRequest(EventRequestModel request) async {
    try {
      await _eventRequestRepository.deleteEventRequest(request.id);
      
      Get.snackbar(
        'Success',
        'Event request cancelled',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel request: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
} 