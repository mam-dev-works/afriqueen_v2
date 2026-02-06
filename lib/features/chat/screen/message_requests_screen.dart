import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/model/message_request_model.dart';
import 'package:afriqueen/features/chat/model/chat_model.dart';
import 'package:afriqueen/features/chat/widget/message_request_item.dart';
import 'package:afriqueen/features/chat/widget/request_chat_item.dart';
import 'package:afriqueen/features/chat/widget/chat_list_item.dart';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:afriqueen/routes/app_routes.dart';

class MessageRequestsScreen extends StatefulWidget {
  const MessageRequestsScreen({super.key});

  @override
  State<MessageRequestsScreen> createState() => _MessageRequestsScreenState();
}

class _MessageRequestsScreenState extends State<MessageRequestsScreen> with TickerProviderStateMixin {
  late TabController _topTabController;
  late TabController _bottomTabController;
  
  int _selectedTopTabIndex = 1; // Demande tab selected
  int _selectedBottomTabIndex = 0;
  int _selectedStatusIndex = 3; // Toutes selected by default for Demande tab

  @override
  void initState() {
    super.initState();
    _topTabController = TabController(length: 5, vsync: this);
    _bottomTabController = TabController(length: 2, vsync: this);
    
    // Load message requests by default (Demande tab)
    context.read<ChatBloc>().add(LoadMessageRequests());
    context.read<ChatBloc>().add(LoadRequestChats());
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
                      _buildTopTab('Message', 0, _selectedTopTabIndex == 0),
                      _buildTopTab('Demande', 1, _selectedTopTabIndex == 1),
                      _buildTopTab('Event', 2, _selectedTopTabIndex == 2),
                      _buildTopTab('Notif', 3, _selectedTopTabIndex == 3),
                      _buildTopTab('Archiv', 4, _selectedTopTabIndex == 4),
                    ],
                  ),
                ),
                
                SizedBox(height: 6.h),
                
                // Second row of tabs - only show for Demande tab
                if (_selectedTopTabIndex == 1) ...[
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBottomTab('Demandes reçus', 0, _selectedBottomTabIndex == 0),
                        _buildBottomTab('Demandes faites', 1, _selectedBottomTabIndex == 1),
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
                        _buildStatusTab('En attente', 0, _selectedStatusIndex == 0),
                        _buildStatusTab('Acceptées', 1, _selectedStatusIndex == 1),
                        _buildStatusTab('Refusées', 2, _selectedStatusIndex == 2),
                        _buildStatusTab('Toutes', 3, _selectedStatusIndex == 3),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Summary statistic
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Nombre de demandes au cours des 7 derniers jours: ',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '58',
                          style: TextStyle(
                            color: Color(0xFFF7BD8E),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    height: 32.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBottomTab('Tous', 0, _selectedBottomTabIndex == 0),
                        _buildBottomTab('Non lu', 2, _selectedBottomTabIndex == 2),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
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
        topTab = 'Message';
        break;
      case 1:
        topTab = 'Demande';
        break;
      case 2:
        topTab = 'Event';
        break;
      case 3:
        topTab = 'Notif';
        break;
      case 4:
        topTab = 'Archiv';
        break;
    }
    
    // Get bottom tab name based on top tab
    if (_selectedTopTabIndex == 1) {
      // Demande tab
      switch (_selectedBottomTabIndex) {
        case 0:
          bottomTab = 'Reçus';
          break;
        case 1:
          bottomTab = 'Faites';
          break;
      }
      
      // Get status tab name
      String statusTab = '';
      switch (_selectedStatusIndex) {
        case 0:
          statusTab = 'En attente';
          break;
        case 1:
          statusTab = 'Acceptées';
          break;
        case 2:
          statusTab = 'Refusées';
          break;
        case 3:
          statusTab = 'Toutes';
          break;
      }
      
      return 'M/D/$bottomTab/$statusTab';
    } else {
      // Other tabs
      switch (_selectedBottomTabIndex) {
        case 0:
          bottomTab = 'Tous';
          break;
        case 2:
          bottomTab = 'Non lu';
          break;
      }
      
      // Return breadcrumb without count
      return 'Messagerie/$topTab/$bottomTab';
    }
  }

  Widget _buildTopTab(String title, int index, bool isSelected) {
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
            
            // Load appropriate data based on selected tab
            if (index == 0) {
              // Message tab - load chats
              context.read<ChatBloc>().add(LoadChats());
            } else if (index == 1) {
              // Demande tab - load message requests
              context.read<ChatBloc>().add(LoadMessageRequests());
              context.read<ChatBloc>().add(LoadRequestChats());
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
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.black,
                fontSize: 12.sp,
                fontWeight: _selectedTopTabIndex == index ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(String title, int count, bool isSelected) {
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
      margin: EdgeInsets.only(right: 8.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedStatusIndex = count;
            });
            
            // Reload data when status changes
            if (_selectedTopTabIndex == 1) {
              context.read<ChatBloc>().add(LoadMessageRequests());
              context.read<ChatBloc>().add(LoadRequestChats());
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

  Widget _buildRequestsList(List<MessageRequestModel> requests, List<ChatModel> requestChats) {
    final allItems = <Widget>[];
    
    // Add message requests
    for (var request in requests) {
      allItems.add(MessageRequestItem(request: request));
    }
    
    // Add request chats
    for (var chat in requestChats) {
      allItems.add(RequestChatItem(chat: chat));
    }

    if (allItems.isEmpty) {
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
              'No requests',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'When someone sends you a message request, it will appear here',
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
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        return allItems[index];
      },
    );
  }

  Widget _buildContent() {
    if (_selectedTopTabIndex == 0) {
      // Message tab - show all chats
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
        },
      );
    } else if (_selectedTopTabIndex == 1) {
      // Demande tab - show message requests
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

          if (state is MessageRequestsLoaded) {
            return _buildRequestsList(state.requests, []);
          }

          if (state is RequestChatsLoaded) {
            return _buildRequestsList([], state.requestChats);
          }

          if (state is RequestsAndRequestChatsLoaded) {
            return _buildRequestsList(state.requests, state.requestChats);
          }

          if (state is ChatListWithRequestsLoaded) {
            return _buildRequestsList(state.requests, []);
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
              'Coming Soon',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This feature is under development',
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
} 