import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AppPermission {
  static Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
        if (Platform.isAndroid) {
      if (await Permission.storage.status.isGranted) {
        return true;
      }
      
      // For Android 13 (API level 33) and above
      if (await Permission.photos.status.isGranted) {
        return true;
      }
      
      // Request both permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.photos,
      ].request();
      
      return statuses[Permission.storage]?.isGranted == true || 
             statuses[Permission.photos]?.isGranted == true;
    } else {
      // For iOS
      PermissionStatus status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  static Future<bool> requestPhotosPermission() async {
    PermissionStatus status = await Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> requestPhonePermission() async {
    PermissionStatus status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<void> openAppSettingsIfDenied(Permission permission) async {
    if (await permission.status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
