import 'dart:io';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String path, String duration) onRecordingComplete;

  const VoiceRecorderWidget({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Microphone permission is required to record voice messages'),
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordedFilePath = '${directory.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordedFilePath!,
        );
        
        setState(() => _isRecording = true);
        
        // Start duration timer
        _startDurationTimer();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      _durationTimer?.cancel();
      setState(() => _isRecording = false);
      
      if (_recordedFilePath != null) {
        widget.onRecordingComplete(
          _recordedFilePath!,
          _formatDuration(_recordingDuration),
        );
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration += Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isRecording ? HugeIcons.strokeRoundedStop : HugeIcons.strokeRoundedMic01,
              color: _isRecording ? AppColors.red : AppColors.primaryColor,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          SizedBox(width: 8.w),
          if (_isRecording) ...[
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 