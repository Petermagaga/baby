import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> uploadProfileImageToFirebase(XFile imageFile) async {
  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}');
    
    final uploadTask = await storageRef.putFile(File(imageFile.path));
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  } catch (e) {
    print('Upload error: $e');
    return null;
  }
}
