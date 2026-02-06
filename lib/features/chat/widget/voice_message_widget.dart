import 'dart:io';
import 'package:afriqueen/common/constant/constant_colors.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String audioUrl;
  final bool isMe;
  final String duration;

  const VoiceMessageWidget({
    Key? key,
    required this.audioUrl,
    required this.isMe,
    required this.duration,
  }) : super(key: key);

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(widget.audioUrl));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: widget.isMe ? AppColors.primaryColor : AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay,
              color: widget.isMe ? AppColors.floralWhite : AppColors.primaryColor,
            ),
            onPressed: _playPause,
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.duration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isMe ? AppColors.floralWhite : AppColors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: 200.w,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                    activeTrackColor: widget.isMe ? AppColors.floralWhite : AppColors.primaryColor,
                    inactiveTrackColor: widget.isMe ? AppColors.floralWhite.withOpacity(0.3) : AppColors.grey.withOpacity(0.3),
                    thumbColor: widget.isMe ? AppColors.floralWhite : AppColors.primaryColor,
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                      setState(() => _position = position);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 