import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/models/ejercicios.dart';

class ReorderExercises extends StatefulWidget {
  final List<EjerciciosDetalladosAgrupados> ejerciciosDetalladosAgrupados;

  const ReorderExercises(
      {Key? key, required this.ejerciciosDetalladosAgrupados})
      : super(key: key);

  @override
  _ReorderExercisesState createState() => _ReorderExercisesState();
}

class _ReorderExercisesState extends State<ReorderExercises> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordenar Grupos de Ejercicios'),
      ),
      body: ReorderableListView(
        children: widget.ejerciciosDetalladosAgrupados
            .asMap()
            .map((index, grupo) =>
                MapEntry(index, _buildGroupCard(grupo, index)))
            .values
            .toList(),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final EjerciciosDetalladosAgrupados item =
                widget.ejerciciosDetalladosAgrupados.removeAt(oldIndex);
            widget.ejerciciosDetalladosAgrupados.insert(newIndex, item);
          });
        },
      ),
    );
  }

  Widget _buildGroupCard(EjerciciosDetalladosAgrupados grupo, int index) {
    return Card(
      key: ValueKey(grupo.groupedDetailedExercisedId ??
          DateTime.now()
              .millisecondsSinceEpoch), // Asegurarse de tener una key única
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const Divider(),
            ...grupo.ejerciciosDetallados.asMap().entries.map((entry) {
              int ejercicioIndex = entry.key;
              EjercicioDetallado ejercicioDetallado = entry.value;
              return ListTile(
                title: Text(
                  '${getExerciseLetter(ejercicioIndex)}. ${ejercicioDetallado.ejercicio?.name ?? 'Ejercicio no especificado'}',
                  style: const TextStyle(fontSize: 16.0),
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
              );
            }).toList(),
          ],
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
}
