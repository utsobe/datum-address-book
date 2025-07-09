import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerService extends GetxService {
  final ImagePicker _imagePicker = ImagePicker();

  static ImagePickerService get to => Get.find();

  /// Pick image from camera or gallery with proper permission handling
  Future<String?> pickImage({
    required bool fromCamera,
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 85,
  }) async {
    try {
      // Check and request permissions
      final hasPermission = await _requestPermissions(fromCamera);
      if (!hasPermission) {
        return null;
      }

      // Show loading for gallery access
      if (!fromCamera) {
        _showLoadingDialog();
      }

      // Pick the image
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        preferredCameraDevice: fromCamera
            ? CameraDevice.front
            : CameraDevice.rear,
      );

      // Close loading dialog if shown
      if (!fromCamera && Get.isDialogOpen == true) {
        Get.back();
      }

      if (image != null) {
        // Save image to app directory
        return await _saveImageToAppDirectory(image);
      } else {
        // User cancelled selection
        if (!fromCamera) {
          Get.snackbar(
            'Cancelled',
            'Photo selection was cancelled.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey[600],
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
        return null;
      }
    } catch (e) {
      print('Error picking image: $e');

      // Close any open dialogs
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      _showErrorSnackbar(fromCamera, e.toString());
      return null;
    }
  }

  /// Request appropriate permissions based on platform and source
  Future<bool> _requestPermissions(bool fromCamera) async {
    try {
      if (fromCamera) {
        // Camera permission
        final cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          _showPermissionDeniedDialog('camera');
          return false;
        }
        return true;
      } else {
        // Gallery permissions - different for iOS and Android
        if (Platform.isIOS) {
          return await _requestIOSGalleryPermission();
        } else {
          return await _requestAndroidGalleryPermission();
        }
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Request iOS gallery permissions with proper handling
  Future<bool> _requestIOSGalleryPermission() async {
    var photosStatus = await Permission.photos.status;

    if (photosStatus.isGranted || photosStatus.isLimited) {
      return true;
    }

    if (photosStatus.isDenied) {
      // Show explanation dialog first
      final shouldRequest = await _showPermissionExplanationDialog();
      if (!shouldRequest) return false;

      photosStatus = await Permission.photos.request();
    }

    if (photosStatus.isGranted || photosStatus.isLimited) {
      return true;
    }

    if (photosStatus.isPermanentlyDenied) {
      _showPermissionDeniedDialog('photo library');
    }

    return false;
  }

  /// Request Android gallery permissions with proper handling
  Future<bool> _requestAndroidGalleryPermission() async {
    // For Android 13+ (API 33+), use READ_MEDIA_IMAGES
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      var photosStatus = await Permission.photos.status;

      // Try storage permission first (for older Android versions)
      if (storageStatus.isDenied) {
        storageStatus = await Permission.storage.request();
      }

      // Try photos permission (for newer Android versions)
      if (photosStatus.isDenied) {
        photosStatus = await Permission.photos.request();
      }

      // Accept if either permission is granted
      if (storageStatus.isGranted || photosStatus.isGranted) {
        return true;
      }

      if (storageStatus.isPermanentlyDenied ||
          photosStatus.isPermanentlyDenied) {
        _showPermissionDeniedDialog('storage');
      }
    }

    return false;
  }

  /// Show permission explanation dialog
  Future<bool> _showPermissionExplanationDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Photo Access Required'),
        content: const Text(
          'To add contact photos, this app needs access to your photo library.\n\n'
          'You can choose to:\n'
          '• Allow access to all photos\n'
          '• Select specific photos\n\n'
          'Your photos will only be used for contact avatars.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show permission denied dialog with settings option
  void _showPermissionDeniedDialog(String permissionType) {
    Get.snackbar(
      'Permission Required',
      'Please grant $permissionType access in Settings to continue.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () {
          openAppSettings();
        },
        child: const Text(
          'Open Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show loading dialog for gallery access
  void _showLoadingDialog() {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Opening photo library...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(bool fromCamera, String error) {
    Get.snackbar(
      'Error',
      fromCamera
          ? 'Failed to capture photo. Please try again.'
          : 'Failed to access photo library. Please check permissions and try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  /// Save picked image to app directory
  Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      // Ensure app directory exists
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      // Save image with unique filename
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(
        image.path,
      ).copy('${avatarsDir.path}/$fileName');

      // Delete the temporary file if it's different from the saved one
      if (image.path != savedImage.path) {
        try {
          await File(image.path).delete();
        } catch (e) {
          // Ignore deletion errors for temporary files
          print('Could not delete temporary file: $e');
        }
      }

      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Delete image file
  Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting image file: $e');
      }
    }
  }
}
