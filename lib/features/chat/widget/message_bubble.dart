import 'package:afriqueen/common/localization/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:afriqueen/features/chat/model/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afriqueen/features/chat/widget/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:afriqueen/common/theme/app_colors.dart';
import 'package:afriqueen/features/chat/widget/voice_message_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final Function(MessageModel) onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isInitialized = false;
  bool _isLoading = true;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    if (widget.message.type == MessageType.voice && widget.message.audioUrl != null) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _audioPlayer.setUrl(widget.message.audioUrl!);
        
        // Listen to player state changes
        _audioPlayer.playerStateStream.listen((state) {
          if (mounted) {
            setState(() {
              _isPlaying = state.playing;
              if (state.processingState == ProcessingState.completed) {
                _position = Duration.zero;
                _isPlaying = false;
              }
            });
          }
        });

        // Listen to position changes
        _audioPlayer.positionStream.listen((position) {
          if (mounted) {
            setState(() {
              _position = position;
            });
          }
        });

        // Listen to duration changes
        _audioPlayer.durationStream.listen((duration) {
          if (mounted && duration != null) {
            setState(() {
              _duration = duration;
              _isInitialized = true;
              _isLoading = false;
            });
          }
        });
      } catch (e) {
        debugPrint('Error initializing audio player: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(EnumLocale.deleteMessage.name.tr),
        content: Text(EnumLocale.questionToDeleteMessage.name.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(EnumLocale.cancel.name.tr),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete(widget.message);
              Navigator.pop(context);
            },
            child: Text(
              EnumLocale.delete.name.tr,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.isMe ? () => _showDeleteDialog(context) : null,
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: widget.isMe ? 60.w : 0,
            right: widget.isMe ? 0 : 60.w,
            bottom: 8.h,
          ),
          child: Column(
            crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: widget.isMe ? Color(0xFF4CAF50) : AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(widget.isMe ? 20.r : 4.r),
                    bottomRight: Radius.circular(widget.isMe ? 4.r : 20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMessageContent(),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  _formatTimestamp(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final messageTime = widget.message.timestamp;
    
    if (messageTime == null) return '';
    
    final difference = now.difference(messageTime);
    
    if (difference.inDays == 0) {
      // Today
      final hour = messageTime.hour.toString().padLeft(2, '0');
      final minute = messageTime.minute.toString().padLeft(2, '0');
      return 'Aujourd\'hui, $hour:$minute';
    } else if (difference.inDays == 1) {
      // Yesterday
      final hour = messageTime.hour.toString().padLeft(2, '0');
      final minute = messageTime.minute.toString().padLeft(2, '0');
      return 'Hier, $hour:$minute';
    } else {
      // Other days
      final hour = messageTime.hour.toString().padLeft(2, '0');
      final minute = messageTime.minute.toString().padLeft(2, '0');
      return '${messageTime.day}/${messageTime.month}, $hour:$minute';
    }
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            color: widget.isMe ? AppColors.white : AppColors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        );
      case MessageType.image:
        return widget.message.imageUrl != null
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        imageUrl: widget.message.imageUrl!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.message.imageUrl!,
                    width: 200.w,
                    height: 200.w,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 2.w,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 200.w,
                      height: 200.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: AppColors.grey,
                        size: 32.sp,
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      EnumLocale.imageNotAvailable.name.tr,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
      case MessageType.voice:
        return widget.message.audioUrl != null
            ? VoiceMessageWidget(
                audioUrl: widget.message.audioUrl!,
                messageId: widget.message.id,
                duration: widget.message.audioDuration,
                isMe: widget.isMe,
              )
            : Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.audiotrack,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      EnumLocale.audioNotAvailable.name.tr,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
      default:
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                EnumLocale.unknownMessageType.name.tr,
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        );
    }
  }
} 