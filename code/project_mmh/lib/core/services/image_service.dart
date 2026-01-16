import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source);
  }

  Future<String> saveImage(XFile imageFile, String subDirectory) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String imagesDirPath = path.join(
      appDocDir.path,
      'patient_images',
      subDirectory,
    );

    final Directory imagesDir = Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final String fileName = path.basename(imageFile.path);
    final String savedPath = path.join(imagesDirPath, fileName);

    await imageFile.saveTo(savedPath);
    return savedPath;
  }

  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
