import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../../../common/constant/constant_strings.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  late final CloudinaryPublic _cloudinary;

  factory CloudinaryService() {
    return _instance;
  }

  CloudinaryService._internal() {
    _cloudinary = CloudinaryPublic(
      AppStrings.cloudName,
      AppStrings.uploadPreset,
      cache: false,
    );
  }

  Future<String> uploadVoiceMessage(File audioFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          audioFile.path,
          resourceType: CloudinaryResourceType.Video,
          folder: 'voice_messages',
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload voice message: $e');
    }
  }
} 