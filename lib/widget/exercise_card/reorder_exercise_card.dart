import 'package:flutter/material.dart';
import 'package:fit_match/models/ejercicios.dart';

class ReorderExercises extends StatefulWidget {
  final List<EjerciciosDetalladosAgrupados> ejerciciosDetalladosAgrupados;

  const ReorderExercises(
      {Key? key, required this.ejerciciosDetalladosAgrupados})
      : super(key: key);

  @override
  ReorderExercisesState createState() => ReorderExercisesState();
}

class ReorderExercisesState extends State<ReorderExercises> {
  void _navigateBack() {
    Navigator.of(context).pop(widget.ejerciciosDetalladosAgrupados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordenar Grupos de Ejercicios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
        ),
      ),

      // Usar ReorderableListView.builder para una gestión más eficiente de los items
      body: ReorderableListView.builder(
        itemCount: widget.ejerciciosDetalladosAgrupados.length,
        itemBuilder: (context, index) {
          // Construye cada item del grupo de ejercicios
          final grupo = widget.ejerciciosDetalladosAgrupados[index];
          return _buildGroupCard(
              grupo, index); // Asegúrate de pasar el índice correcto
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            final EjerciciosDetalladosAgrupados item =
                widget.ejerciciosDetalladosAgrupados.removeAt(oldIndex);
            widget.ejerciciosDetalladosAgrupados
                .insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
          });
        },
      ),
    );
  }

  Widget _buildGroupCard(EjerciciosDetalladosAgrupados grupo, int index) {
    // Usa el índice o un identificador único del grupo como parte de la Key
    return Card(
      key: ValueKey('grupo_${grupo.groupedDetailedExercisedId ?? index}'),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grupo ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const Divider(),
            ...grupo.ejerciciosDetallados.map((ejercicioDetallado) {
              return ListTile(
                title: Text(
                  ejercicioDetallado.ejercicio?.name ??
                      'Ejercicio no especificado',
                  style: const TextStyle(fontSize: 16.0),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
