import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(File audioFile, int duration) onRecordingComplete;

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
  int _recordDuration = 0;
  Timer? _timer;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }

  Future<void> _cleanupOldRecording() async {
    if (_recordedFilePath != null) {
      final oldFile = File(_recordedFilePath!);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Clean up any existing recording
        await _cleanupOldRecording();
        
        final directory = await getTemporaryDirectory();
        final uniqueId = _uuid.v4();
        _recordedFilePath = '${directory.path}/audio_${uniqueId}.m4a';
        
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordedFilePath!,
        );
        
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            _recordDuration++;
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        final file = File(path);
        if (await file.exists() && await file.length() > 0) {
          widget.onRecordingComplete(file, _recordDuration);
        } else {
          debugPrint('Recording file is empty or does not exist');
        }
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) {
      _audioRecorder.stop();
    }
    _cleanupOldRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            onPressed: _isRecording ? _stopRecording : _startRecording,
            color: _isRecording ? Colors.red : Colors.blue,
          ),
          if (_isRecording) ...[
            const SizedBox(width: 8),
            Text(
              _formatDuration(_recordDuration),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 