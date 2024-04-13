import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/home/historial/estadisticas_registro.dart';
import 'package:fit_match/screens/client/training/register_training/register_training.dart';
import 'package:fit_match/services/registro_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistroHistorialCard extends StatelessWidget {
  final SesionEntrenamiento session;
  final RegistroDeSesion registro;
  final User user;
  final Function(RegistroDeSesion) onDelete;
  RegistroHistorialCard(
      {required this.session,
      required this.registro,
      required this.user,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Asegura que la tarjeta sea tan grande como sus hijos
            children: [
              ListTile(
                trailing: Wrap(spacing: 12, children: [
                  IconButton(
                    onPressed: () => _verEstadisticas(context),
                    icon: const Icon(Icons.insert_chart_outlined_rounded),
                  ),
                  PopupMenuButton<String>(
                    color: Theme.of(context).colorScheme.primary,
                    onSelected: (value) =>
                        _handleMenuItemSelected(value, context),
                    itemBuilder: (BuildContext context) =>
                        _buildPopupMenuItems(context),
                  ),
                ]),
                title: Wrap(spacing: 6, children: [
                  Text(
                    session.sessionName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(DateFormat.yMMMMd('es_ES').format(registro.final_date!),
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTitle(context),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (session.ejerciciosDetalladosAgrupados != null)
                          for (EjerciciosDetalladosAgrupados exercise
                              in session.ejerciciosDetalladosAgrupados!) ...[
                            for (int i = 0;
                                i < exercise.ejerciciosDetallados.length;
                                i++) ...[
                              buildListItem(
                                  exercise.ejerciciosDetallados[i], context),
                            ]
                          ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getRegistrosSetNumber(
      EjercicioDetallado ejerciciosDetallados, int idRegistroSession) {
    if (ejerciciosDetallados.setsEntrada == null) {
      return 0;
    }
    // Filtrar los sets de ejercicios para incluir solo aquellos con un registro de sesión que coincida con el id proporcionado
    return ejerciciosDetallados.setsEntrada!
        .where((setEntrada) =>
            setEntrada.registroSet !=
            null) // Asegurarse de que registroSet no es nulo
        .fold(0, (count, setEntrada) {
      // Contar solo los registros de set que coincidan con idRegistroSession
      return count +
          setEntrada.registroSet!
              .where(
                  (registro) => registro.registerSessionId == idRegistroSession)
              .length;
    });
  }

  buildListItem(EjercicioDetallado ejerciciosDetallados, BuildContext context) {
    return ExpansionTile(
      title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                ejerciciosDetallados.ejercicio!.name,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              '${_getRegistrosSetNumber(ejerciciosDetallados, registro.registerSessionId)} Sets',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ]),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...buildContentEjercicioDetallado(
                      ejerciciosDetallados, registro, user.system, context),
                ],
              )),
        ),
      ],
    );
  }

  List<Widget> buildContentEjercicioDetallado(
      EjercicioDetallado ejerciciosDetallados,
      RegistroDeSesion registro,
      String system,
      BuildContext context) {
    List<String> setStrings =
        formatExerciseSets(ejerciciosDetallados, registro, system);

    return setStrings
        .map((setString) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                setString,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ))
        .toList();
  }

  buildTitle(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 24.0),
      child: Row(children: [
        Expanded(
          child: Text(
            "Ejercicio",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Sets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(context) {
    return [
      PopupMenuItem<String>(
          value: 'stats',
          child: Text('Ver estadísticas',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.background))),
      PopupMenuItem<String>(
          value: 'delete',
          child: Text('Eliminar',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.background))),
      PopupMenuItem<String>(
          value: 'editar',
          child: Text('Editar',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.background))),
    ];
  }

  void _handleMenuItemSelected(String value, BuildContext context) {
    switch (value) {
      case 'stats':
        _verEstadisticas(context);
        break;
      case 'delete':
        _onWillPop(context);

      case 'editar':
        _editarRegistro(context);
        break;
    }
  }

  List<String> formatExerciseSets(EjercicioDetallado ejerciciosDetallados,
      RegistroDeSesion registro, String system) {
    String unit = (system == "metrico") ? "kg" : "lbs";

    if (ejerciciosDetallados.setsEntrada == null ||
        ejerciciosDetallados.setsEntrada!.isEmpty) {
      return [];
    }

    List<String> formattedSets = [];

    for (var setEntrada in ejerciciosDetallados.setsEntrada!) {
      var registrosSets = setEntrada.registroSet
              ?.where((element) =>
                  element.registerSessionId == registro.registerSessionId)
              .toList() ??
          [];
      if (registrosSets.isEmpty) continue;

      for (int i = 0; i < registrosSets.length; i++) {
        RegistroSet registroSet = registrosSets[i];
        formattedSets.add(formatSet(
            registroSet, i + 1, ejerciciosDetallados.registerTypeId, unit));
      }
    }

    return formattedSets;
  }

  String formatSet(
      RegistroSet registroSet, int setNumber, int registerTypeId, String unit) {
    if (registroSet.weight != null) {
      (unit == "lbs")
          ? registroSet.weight = fromKgToLbs(registroSet.weight!)
          : null;
    }
    switch (registerTypeId) {
      case 4: // AMRAP
        return "Set $setNumber: AMRAP";
      case 5: // tiempo
        return "Set $setNumber: ${registroSet.time?.toStringAsFixed(2) ?? 0} min";
      case 6: // rango de tiempo
        return "Set $setNumber: ${registroSet.time?.toStringAsFixed(2) ?? '0'} min x ${registroSet.weight ?? '0'} $unit";
      default:
        return "Set $setNumber: ${registroSet.reps ?? 0} reps x ${registroSet.weight ?? 0} $unit";
    }
  }

  void _verEstadisticas(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EstadisticasRegistroScreen(
                  session: session,
                  user: user,
                )));
  }

  void _editarRegistro(BuildContext context) async {
    bool exito =
        await RegistroMethods().terminarRegistro(registro.registerSessionId);
    if (exito) {
      _navigateToEditSession(context);
    }
  }

  void _navigateToEditSession(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterTrainingScreen(
                  sessionId: session.sessionId,
                  user: user,
                )));
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estás seguro?'),
        content: const Text('Se eliminará el registro.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(
                false), // Esto cierra el cuadro de diálogo devolviendo 'false'.
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                  true); // Esto cierra el cuadro de diálogo devolviendo 'true'.
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (shouldPop ?? false) {
      onDelete(registro);
    }

    return Future.value(
        false); // Evita que el botón de retroceso cierre la pantalla automáticamente.
  }
}
