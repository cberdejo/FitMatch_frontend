import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';

import 'package:fit_match/services/sesion_entrenamientos_service.dart';

import 'package:fit_match/widget/exercise_card/info_exercise_card.dart';
import 'package:flutter/material.dart';

class OverviewPlantilla extends StatefulWidget {
  final User user;
  final int templateId;
  final String templateName;

  const OverviewPlantilla({
    super.key,
    required this.user,
    required this.templateId,
    required this.templateName,
  });
  @override
  _OverviewPlantilla createState() => _OverviewPlantilla();
}

class _OverviewPlantilla extends State<OverviewPlantilla> {
  List<SesionEntrenamiento> sesiones = [];

  @override
  void initState() {
    super.initState();
    initSesionEntrenamientos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initSesionEntrenamientos() async {
    try {
      // Obtener nuevos posts.
      var sesiones = await SesionEntrenamientoMethods()
          .getSesionesEntrenamientoByTemplateId(widget.templateId);

      // Actualizar la lista de posts y el estado si el componente sigue montado.
      if (mounted) {
        setState(() {
          this.sesiones = sesiones;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        constraints: const BoxConstraints(maxWidth: 1000),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildEntrenamientosList(context),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildEntrenamientosList(BuildContext context) {
    if (sesiones.isEmpty) {
      return const Text(
        'No hay sesiones de entrenamiento todavía',
        style: TextStyle(fontSize: 18),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: sesiones.length,
      itemBuilder: (context, index) => _buildListItem(context, index),
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    List<EjerciciosDetalladosAgrupados>? ejerciciosDetalladosAgrupados =
        sesiones[index].ejerciciosDetalladosAgrupados;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ExpansionTile(
        title: Text(sesiones[index].sessionName),
        controlAffinity: ListTileControlAffinity.leading,
        children: ejerciciosDetalladosAgrupados != null
            ? ejerciciosDetalladosAgrupados.asMap().entries.map((entry) {
                var groupIndex = entry.key;
                var grupo = entry.value;
                return buildInfoGroupCard(context, grupo, groupIndex);
              }).toList()
            : [Container()],
      ),
    );
  }
}
