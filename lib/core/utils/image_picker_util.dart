import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// A picked image held fully in memory (works on mobile and web).
class PickedImage {
  final Uint8List bytes;
  final String name;

  const PickedImage({required this.bytes, required this.name});

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot >= 0 && dot < name.length - 1 ? name.substring(dot) : '.jpg';
  }
}

/// Picks a single image from the gallery, read into memory.
Future<PickedImage?> pickSingleImage() async {
  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82);
  if (file == null) return null;
  return PickedImage(bytes: await file.readAsBytes(), name: file.name);
}

/// Picks multiple images from the gallery, read into memory.
Future<List<PickedImage>> pickMultipleImages() async {
  final files = await ImagePicker().pickMultiImage(imageQuality: 82);
  final result = <PickedImage>[];
  for (final f in files) {
    result.add(PickedImage(bytes: await f.readAsBytes(), name: f.name));
  }
  return result;
}
