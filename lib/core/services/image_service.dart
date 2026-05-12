import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(ImageSource source) async {
    try {
      // Request permissions first
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isDenied) return null;
      } else {
        // For gallery, handling depends on platform version, but standard request works for most
        if (Platform.isAndroid) {
           // On Android 13+ it might be different, but permission_handler handles it well
           await Permission.photos.request();
        } else {
           await Permission.photos.request();
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Compress for offline storage
        maxWidth: 1000,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File?> showImageSourceDialog(dynamic context) async {
    // This is a placeholder since we want to keep logic decoupled from UI
    // But for a utility service, we can provide the logic
    return null; 
  }
}
