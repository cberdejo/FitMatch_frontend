import 'package:flutter/material.dart';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/utils/utils.dart';

Widget buildInfoGroupCard(
    BuildContext context, EjerciciosDetalladosAgrupados grupo, int groupIndex) {
  return Card(
    key: ValueKey(grupo.groupedDetailedExercisedId ??
        DateTime.now().millisecondsSinceEpoch),
    margin: const EdgeInsets.all(8.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grupo.ejerciciosDetallados.asMap().entries.map((entry) {
          int ejercicioIndex = entry.key;
          EjercicioDetallado ejercicioDetallado = entry.value;
          String letterExercise = grupo.ejerciciosDetallados.length > 1
              ? '${getExerciseLetter(ejercicioIndex)}'
              : '';
          String tituloUnico = '${groupIndex + 1}$letterExercise';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tituloUnico,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                  title: Text(
                    ejercicioDetallado.ejercicio?.name ??
                        'Ejercicio no especificado',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showDialog(
                          ejercicioDetallado.ejercicio?.description ??
                              'Sin descripción',
                          context);
                    },
                  ),
                  subtitle: Text(
                      "${ejercicioDetallado.setsEntrada?.length ?? 0} Sets")),
            ],
          );
        }).toList(),
      ),
    ),
  );
}

void _showDialog(String description, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
