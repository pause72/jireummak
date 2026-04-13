import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WishImageLocalStore {
  WishImageLocalStore._();

  static String _filePath(String docsDir, String itemId) =>
      '$docsDir/wish_images/$itemId.jpg';

  /// Copies the picked image to the app documents directory.
  static Future<void> save(String itemId, XFile source) async {
    final docsDir = await _docsDir();
    final imagesDir = Directory('$docsDir/wish_images');
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    await File(source.path).copy(_filePath(docsDir, itemId));
  }

  /// Deletes the stored image for the given item ID.
  static Future<void> delete(String itemId) async {
    final docsDir = await _docsDir();
    final file = File(_filePath(docsDir, itemId));
    if (await file.exists()) await file.delete();
  }

  /// Returns the File if an image exists for the given item ID, otherwise null.
  static Future<File?> getFile(String itemId) async {
    final docsDir = await _docsDir();
    final file = File(_filePath(docsDir, itemId));
    return (await file.exists()) ? file : null;
  }

  static Future<String> _docsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
