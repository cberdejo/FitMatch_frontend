import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:flutter/material.dart';

class BuildExerciseItem extends StatelessWidget {
  final Ejercicios ejercicio;
  bool isSelected;
  final ValueChanged<Ejercicios> onSelectedEjercicio;
  final void Function() onPressedInfo;
  final int? order;
  BuildExerciseItem({
    required this.ejercicio,
    this.isSelected = false,
    required this.onSelectedEjercicio,
    required this.onPressedInfo,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final style = isSelected
        ? const TextStyle(
            color: blueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          )
        : const TextStyle(
            fontSize: 14,
          );

    return Card(
      child: ListTile(
        title: Text(ejercicio.name,
            style: style,
            textScaler: width < webScreenSize
                ? const TextScaler.linear(1)
                : const TextScaler.linear(1.5)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            trailingWidget(),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                onPressedInfo();
              },
            ),
          ],
        ),
        onTap: () {
          onSelectedEjercicio(ejercicio);
        },
      ),
    );
  }

  Widget trailingWidget() {
    if (isSelected && order != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: blueColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          order.toString(),
          style: const TextStyle(
            color: primaryColor,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
