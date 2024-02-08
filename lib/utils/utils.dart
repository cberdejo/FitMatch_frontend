import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_templates/view_training_screen.dart';
import 'package:fit_match/widget/preferences.dart';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/screens/client/home/view_plantillas_post_screen.dart';
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
  return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
}

// for formatting time
String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  final int days = difference.inDays;
  final int hours = difference.inHours;
  final int minutes = difference.inMinutes;

  String pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }

  if (days >= 365) {
    final int years = (days / 365).floor();
    return 'hace $years ${pluralize(years, 'año', 'años')}';
  } else if (days >= 30) {
    final int months = (days / 30).floor();
    return 'hace $months ${pluralize(months, 'mes', 'meses')}';
  } else if (days >= 7) {
    final int weeks = (days / 7).floor();
    return 'hace $weeks ${pluralize(weeks, 'semana', 'semanas')}';
  } else if (days == 1) {
    return 'hace 1 día';
  } else if (days > 0) {
    return 'hace $days días';
  } else if (hours == 1) {
    return 'hace 1 hora';
  } else if (hours > 0) {
    return 'hace $hours horas';
  } else if (minutes == 1) {
    return 'hace 1 minuto';
  } else if (minutes > 0) {
    return 'hace $minutes minutos';
  } else {
    return 'Justo ahora';
  }
}

//for displaying toast
void showToast(BuildContext context, String message, {bool exitoso = true}) {
  final snackBar = SnackBar(
    content: Text(message,
        style:
            const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
    backgroundColor: exitoso ? Colors.green : Colors.red,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// for getting horizontal padding
EdgeInsets getHorizontalPadding(BuildContext context) {
  return MediaQuery.of(context).size.width > webScreenSize
      ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 4)
      : const EdgeInsets.symmetric(horizontal: 32);
}

//for getting preferences
List<CheckboxPreference> objetivosOptions = [
  CheckboxPreference(title: 'Pérdida de peso'),
  CheckboxPreference(title: 'Ganancia muscular'),
  CheckboxPreference(title: 'Resistencia cardiovascular'),
  CheckboxPreference(title: 'Flexibilidad y movilidad'),
  CheckboxPreference(title: 'Salud'),
  CheckboxPreference(title: 'Rehabilitacion'),
  CheckboxPreference(title: 'Otros'),
];

List<CheckboxPreference> interesesOptions = [
  CheckboxPreference(title: 'Culturismo'),
  CheckboxPreference(title: 'Artes marciales'),
  CheckboxPreference(title: 'Boxeo'),
  CheckboxPreference(title: 'Ciclismo'),
  CheckboxPreference(title: 'Gimnasia'),
  CheckboxPreference(title: 'Natación'),
  CheckboxPreference(title: 'Halterofilia'),
  CheckboxPreference(title: 'Pilates'),
  CheckboxPreference(title: 'Strongman'),
  CheckboxPreference(title: 'Yoga'),
  CheckboxPreference(title: 'Zumba'),
  CheckboxPreference(title: 'Crossfit'),
  CheckboxPreference(title: 'Calistenia'),
  CheckboxPreference(title: 'Otros'),
];

List<RadioPreference<String>> experienciaOptions = [
  RadioPreference(title: 'Principiante', value: 'Principiante'),
  RadioPreference(title: 'Intermedio', value: 'Intermedio'),
  RadioPreference(title: 'Avanzado', value: 'Avanzado'),
];

List<RadioPreference<String>> equipmentOptions = [
  RadioPreference(title: 'Gimnasio completo', value: 'Gimnasio completo'),
  RadioPreference(title: 'Mancuernas y barras', value: 'Mancuernas y barras'),
  RadioPreference(title: 'Solo mancuernas', value: 'Solo mancuernas'),
  RadioPreference(title: 'Solo barras', value: 'Solo barra'),
  RadioPreference(
      title: 'Nada (sin equipamiento)', value: 'Nada (sin equipamiento)'),
];

List<RadioPreference<String>> durationOptions = [
  RadioPreference(title: '15 minutos o menos', value: '15 minutos o menos'),
  RadioPreference(title: '30 minutos', value: '30 minutos'),
  RadioPreference(
      title: 'Entre 30 minutos y 1 hora', value: 'Entre 30 minutos y 1 hora'),
  RadioPreference(
      title: 'Entre 1 hora  y 1 hora y 30 minutos',
      value: 'Entre 1 hora  y 1 hora y 30 minutos'),
  RadioPreference(
      title: 'Entre 1 hora y 30 minutos 2 horas',
      value: 'Entre 1 hora y 30 minutos 2 horas'),
  RadioPreference(title: 'Mas de 2 horas', value: 'Mas de 2 horas'),
];

// for displaying screens
List<Widget> buildHomeScreenItems(User user) {
  return [
    ViewTrainersScreen(user: user),
    const Text('b'),
    const Text('c'),
    ViewTrainingScreen(user: user),
    const Text('e'),
  ];
}
