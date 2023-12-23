import 'package:fit_match/models/review.dart';
import 'package:fit_match/screens/client/view_trainers_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';

// for picking up image from gallery
pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
}

// for calculating average rating
num calculateAverageRating(List<Review> reviews) {
  if (reviews.isEmpty) return 0;
  return reviews.map((r) => r.rating).reduce((a, b) => a + b) ~/ reviews.length;
}

// for formatting time
String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays >= 365) {
    final int years = (difference.inDays / 365).floor();
    return 'hace $years ${years == 1 ? 'año' : 'años'}';
  } else if (difference.inDays >= 30) {
    final int months = (difference.inDays / 30).floor();
    return 'hace $months ${months == 1 ? 'mes' : 'meses'}';
  } else if (difference.inDays >= 7) {
    final int weeks = (difference.inDays / 7).floor();
    return 'hace $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
  } else if (difference.inDays == 1) {
    return 'hace 1 día';
  } else if (difference.inDays > 0) {
    return 'hace ${difference.inDays} días';
  } else if (difference.inHours == 1) {
    return 'hace 1 hora';
  } else if (difference.inHours > 0) {
    return 'hace ${difference.inHours} horas';
  } else if (difference.inMinutes == 1) {
    return 'hace 1 minuto';
  } else if (difference.inMinutes > 0) {
    return 'hace ${difference.inMinutes} minutos';
  } else {
    return 'Justo ahora';
  }
}

//for displaying toast
void showToast(BuildContext context, String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: secondaryColor,
      textColor: primaryColor,
      webPosition: "right",
      fontSize: 16.0);
}

// for getting horizontal padding
EdgeInsets getHorizontalPadding(BuildContext context) {
  return MediaQuery.of(context).size.width > webScreenSize
      ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 4)
      : const EdgeInsets.symmetric(horizontal: 32);
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
