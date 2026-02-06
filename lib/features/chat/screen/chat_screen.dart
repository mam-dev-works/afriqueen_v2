import 'dart:convert';
import 'dart:io';
import 'package:afriqueen/features/chat/bloc/chat_bloc.dart';
import 'package:afriqueen/features/chat/model/message_model.dart';
import 'package:afriqueen/features/login/repository/login_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afriqueen/features/chat/widget/message_bubble.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:afriqueen/features/chat/repository/chat_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/localization/enums/enums.dart';
import '../../../common/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String receiverPhotoUrl;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhotoUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _reportReasonController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AudioRecorder _audioRecorder;
  late final ChatRepository _chatRepository;
  bool _isRecording = false;
  String? _recordingPath;
  Duration _recordingDuration = Duration.zero;
  late final ChatBloc _chatBloc;
  late final LoginRepository loginRepository;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _chatBloc = context.read<ChatBloc>();
    _chatRepository = ChatRepository();
    _chatBloc.add(LoadMessages(widget.chatId));
    _chatBloc.add(MarkMessagesAsRead(widget.chatId));
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final hasPermission = await Permission.microphone.request();
    if (hasPermission.isGranted) {
      await _audioRecorder.hasPermission();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _reportReasonController.dispose();
    _scrollController.dispose();
    if (_isRecording) {
      _audioRecorder.stop();
    }
    _audioRecorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<bool> _requestPermission() async {
    final hasPermission = await Permission.microphone.request();
    return hasPermission.isGranted;
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _requestPermission();
      if (!hasPermission) return;

      final directory = await getTemporaryDirectory();
      _recordingPath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero; // Reset duration when starting new recording
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration += const Duration(milliseconds: 100);
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) return;

      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        final audioFile = File(path);
        if (await audioFile.exists()) {
          final formattedDuration = _formatDuration(_recordingDuration);
          debugPrint('Recording duration: $formattedDuration');
          debugPrint('Audio file path: ${audioFile.path}');
          debugPrint('Audio file exists: ${await audioFile.exists()}');
          debugPrint('Audio file size: ${await audioFile.length()}');

          if (await audioFile.length() > 0) {
            if (mounted) {
              // Create a temporary message ID to track the upload
              final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();
              
              // Add the message to the state immediately with loading status
              _chatBloc.add(
                SendMessage(
                  chatId: widget.chatId,
                  receiverId: widget.receiverId,
                  content: formattedDuration,
                  type: MessageType.voice,
                  imageFile: audioFile,
                  tempMessageId: tempMessageId,
                ),
              );

              // Start listening for the message update
              _startListeningForMessageUpdate(tempMessageId);
            }
          } else {
            debugPrint('Audio file is empty');
          }
        } else {
          debugPrint('Audio file does not exist at path: $path');
        }
      } else {
        debugPrint('No recording path returned from stop()');
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
  }

  void _startListeningForMessageUpdate(String tempMessageId) {
    // Listen to the specific message in Firebase
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('tempId', isEqualTo: tempMessageId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        if (doc.data()['audioUrl'] != null) {
          // Message has been uploaded, update the UI
          _chatBloc.add(UpdateMessageStatus(
            chatId: widget.chatId,
            messageId: doc.id,
            isUploaded: true,
          ));
        }
      }
    });
  }

  void _handleVoiceRecorded(String filePath) {
    debugPrint('Voice recording handled in _stopRecording');
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatBloc.add(
        SendMessage(
          chatId: widget.chatId,
          receiverId: widget.receiverId,
          content: message,
          type: MessageType.text,
        ),
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (await imageFile.exists()) {
        _chatBloc.add(
              SendMessage(
                chatId: widget.chatId,
                receiverId: widget.receiverId,
                content: '',
                // Will be set to Cloudinary URL after upload
                type: MessageType.image,
                imageFile: imageFile,
              ),
            );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _deleteMessage(MessageModel message) {
    _chatBloc.add(
          DeleteMessage(
            chatId: widget.chatId,
            messageId: message.id,
          ),
        );
  }

  Future<void> _showReportDialog() async {
    try {
      final hasReported = await _chatRepository.hasUserReported(widget.receiverId);
      if (hasReported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(EnumLocale.alreadyReportedUser.name.tr)),
          );
        }
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.report_problem,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      EnumLocale.reportUserTitle.name.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  EnumLocale.reportUserDescription.name.tr,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reportReasonController,
                  decoration: InputDecoration(
                    hintText: EnumLocale.enterReportReason.name.tr,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[200]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        EnumLocale.cancel.name.tr,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_reportReasonController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(EnumLocale.pleaseEnterReason.name.tr)),
                          );
                          return;
                        }

                        try {
                          await _chatRepository.reportUser(
                            reportedUserId: widget.receiverId,
                            chatId: widget.chatId,
                            reason: _reportReasonController.text.trim(),
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(EnumLocale.userReportedSuccess.name.tr)),
                            );
                            _reportReasonController.clear();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(EnumLocale.errorWithMessage.name.trParams({'msg': e.toString()}))),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        EnumLocale.submitReport.name.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(EnumLocale.errorWithMessage.name.trParams({'msg': e.toString()}))),
        );
      }
    }
  }

  Widget _buildInputArea() {
    return Container(
      margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h, top: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Plus icon on the left
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.add,
              color: AppColors.black,
              size: 22.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
          // Rounded input pill in the center
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE3E3E3),
                    Color(0xFFD9D9D9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    offset: const Offset(-1, -1),
                    blurRadius: 2.r,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(2, 2),
                    blurRadius: 4.r,
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: TextStyle(
                    color: AppColors.grey.withOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Send and mic icons on the right
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.send_rounded,
              color: AppColors.black,
              size: 22.sp,
            ),
            onPressed: _sendMessage,
          ),
          SizedBox(width: 10.w),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording ? Colors.red : AppColors.black,
              size: 22.sp,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black,
            size: 24.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: widget.receiverPhotoUrl != null && widget.receiverPhotoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.receiverPhotoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.grey.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 20.sp,
                            color: AppColors.grey,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.grey.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 20.sp,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.grey.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 20.sp,
                          color: AppColors.grey,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.receiverName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    EnumLocale.chatOnlineAgo.name.trParams({'time': '19 heures'}),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_off,
              color: AppColors.grey,
              size: 22.sp,
            ),
            onPressed: () {
              // Mute functionality
            },
          ),
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: AppColors.grey,
              size: 22.sp,
            ),
            onPressed: _showReportDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                buildWhen: (previous, current) =>
                    current is ChatLoading || current is MessagesLoaded,
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 3.w,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            EnumLocale.messagesLoading.name.tr,
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is MessagesLoaded) {
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
                        
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          onDelete: _deleteMessage,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            if (_isRecording)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.red[200]!,
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        color: Colors.red,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      _formatDuration(_recordingDuration),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.stop,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        onPressed: _stopRecording,
                      ),
                    ),
                  ],
                ),
              ),
            SafeArea(
              top: false,
              left: false,
              right: false,
              minimum: EdgeInsets.only(bottom: 8.h),
              child: _buildInputArea(),
            ),
          ],
        ),
      ),
    );
  }
}
