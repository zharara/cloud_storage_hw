import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

Future<UploadTask> uploadFile(File file) async {
  final storageRef = FirebaseStorage.instance.ref();

  final extension = file.path.split('.').last;

  final fileRef = storageRef.child(
      '${DateTime.now().toLocal().toString()}.$extension');

  return fileRef.putFile(file);
}

Stream<ListResult> getAllFiles(){
 return FirebaseStorage.instance.ref().listAll().asStream();
}