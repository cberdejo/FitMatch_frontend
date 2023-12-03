import 'package:fit_match/screens/client/view_trainers_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
}

// for displaying screens
List<Widget> homeScreenItems = [
  const ViewTrainersScreen(),
  const Text('b'),
  const Text('c'),
  const Text('d'),
  const Text('e'),
  const Text('f'),
  const Text('g'),
];
