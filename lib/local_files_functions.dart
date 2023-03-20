import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickFile() async {
  final file = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
  );

  return file?.files.first;
}
