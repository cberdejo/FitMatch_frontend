import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';

class BuildExerciseItem extends StatelessWidget {
  final num userId;
  final num profiledId;
  final Ejercicios ejercicio;
  bool isSelected;
  final ValueChanged<Ejercicios> onSelectedEjercicio;
  final void Function() onPressedInfo;
  void Function()? onEditExercise;
  final void Function() onDeletedExercise;
  final int? order;
  BuildExerciseItem({
    required this.ejercicio,
    this.isSelected = false,
    required this.onSelectedEjercicio,
    required this.onPressedInfo,
    this.order,
    this.onEditExercise,
    required this.onDeletedExercise,
    required this.userId,
    required this.profiledId,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final style = isSelected
        ? TextStyle(
            color: Theme.of(context).colorScheme.primary,
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
            trailingWidget(context),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                onPressedInfo();
              },
            ),
            if ((ejercicio.userId != null && ejercicio.userId == userId) ||
                (profiledId == adminId)) ...[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDeletedExercise();
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  onEditExercise!();
                },
              ),
            ]
          ],
        ),
        onTap: () {
          onSelectedEjercicio(ejercicio);
        },
      ),
    );
  }

  Widget trailingWidget(BuildContext context) {
    if (isSelected && order != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Text(
          order.toString(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
