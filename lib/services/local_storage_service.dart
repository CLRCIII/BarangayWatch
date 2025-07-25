import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  /// Saves an image file to local app storage and returns the path
  static Future<String> saveImage(File imageFile) async {
    try {
      // Get the application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      // Create a reports directory if it doesn't exist
      final reportsDir = Directory('$appDocPath/reports');
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      // Generate a unique filename with timestamp
      final String fileName =
          'report_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${reportsDir.path}/$fileName';

      // Copy the image file to the new location
      final File newImage = await imageFile.copy(filePath);

      return newImage.path;
    } catch (e) {
      throw Exception('Failed to save image locally: $e');
    }
  }

  /// Deletes an image file from local storage
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Gets the file from a path
  static File getImageFile(String imagePath) {
    return File(imagePath);
  }
}
