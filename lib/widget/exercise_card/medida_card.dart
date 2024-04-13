import 'package:fit_match/models/medidas.dart';

import 'package:fit_match/models/user.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/imagen_detailed.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedidaCard extends StatelessWidget {
  final Medidas medida;
  final User user;
  final Function(int) onDelete;
  final Function(Medidas medida) onEdit;
  const MedidaCard({
    super.key,
    required this.medida,
    required this.user,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                trailing: Wrap(spacing: 12, children: [
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
                    DateFormat.yMMMMd('es_ES').format(medida.timestamp!),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoCard(),
                    buildFotosProgresoSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard() {
    String weightSystem = user.system == 'metrico' ? 'kg' : 'lbs';
    String heightSystem = user.system == 'metrico' ? 'cm' : 'in';

    return ExpansionTile(
      title: const Text(
        'Medidas',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        (medida.weight == null)
            ? Container()
            : medidaSection('Peso',
                '${(user.system == 'imperial') ? fromKgToLbs(medida.weight!) : medida.weight} $weightSystem'),
        (medida.leftArm == null)
            ? Container()
            : medidaSection('Brazo izquierdo',
                '${(user.system == 'imperial') ? fromCmToInches(medida.leftArm!) : medida.leftArm} $heightSystem'),
        (medida.rightArm == null)
            ? Container()
            : medidaSection('Brazo derecho',
                '${(user.system == 'imperial') ? fromCmToInches(medida.rightArm!) : medida.rightArm} $heightSystem'),
        (medida.waist == null)
            ? Container()
            : medidaSection('Cintura',
                '${(user.system == 'imperial') ? fromCmToInches(medida.waist!) : medida.waist} $heightSystem'),
        (medida.upperLeftLeg == null)
            ? Container()
            : medidaSection('Muslo izquierdo',
                '${(user.system == 'imperial') ? fromCmToInches(medida.upperLeftLeg!) : medida.upperLeftLeg} $heightSystem'),
        (medida.upperRightLeg == null)
            ? Container()
            : medidaSection('Muslo derecho',
                '${(user.system == 'imperial') ? fromCmToInches(medida.upperRightLeg!) : medida.upperRightLeg} $heightSystem'),
        (medida.leftCalve == null)
            ? Container()
            : medidaSection('Gemelo izquierdo',
                '${(user.system == 'imperial') ? fromCmToInches(medida.leftCalve!) : medida.leftCalve} $heightSystem'),
        (medida.leftCalve == null)
            ? Container()
            : medidaSection('Gemelo derecho',
                '${(user.system == 'imperial') ? fromCmToInches(medida.leftCalve!) : medida.leftCalve} $heightSystem'),
        (medida.shoulders == null)
            ? Container()
            : medidaSection('Hombros',
                '${(user.system == 'imperial') ? fromCmToInches(medida.shoulders!) : medida.shoulders} cm'),
        (medida.chest == null)
            ? Container()
            : medidaSection('Pecho',
                '${(user.system == 'imperial') ? fromCmToInches(medida.chest!) : medida.chest} cm'),
        (medida.neck == null)
            ? Container()
            : medidaSection('Cuello',
                '${(user.system == 'imperial') ? fromCmToInches(medida.neck!) : medida.neck} cm'),
      ],
    );
  }

  Widget buildFotosProgresoSection(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double imageSize = width < webScreenSize ? 100 : 150;
    // Verifica si hay fotos de progreso
    if (medida.fotosProgreso == null || medida.fotosProgreso!.isEmpty) {
      return Container(); // No mostrar sección si no hay fotos
    }

    // Muestra las fotos en un GridView o ListView
    return ExpansionTile(
      title: const Text(
        "Fotos de Progreso",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Para que el GridView no sea desplazable
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Número de columnas
            crossAxisSpacing: 4, // Espaciado horizontal
            mainAxisSpacing: 4, // Espaciado vertical
          ),
          itemCount: medida.fotosProgreso!.length,
          itemBuilder: (context, index) {
            var foto = medida.fotosProgreso![index];
            return GestureDetector(
                onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageDetail(imageData: foto.imagen),
                      ),
                    ),
                child: Image.network(
                  foto.imagen,
                  width: imageSize,
                  height: imageSize,
                ));
          },
        ),
      ],
    );
  }

  Widget medidaSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 30),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(context) {
    return [
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
      case 'delete':
        _onWillPop(context);

      case 'editar':
        onEdit(medida);
        break;
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estás seguro?'),
        content: const Text('Se eliminará el registro de la medida.'),
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

    // Si shouldPop es true, entonces navega hacia atrás.
    if (shouldPop ?? false) {
      onDelete(medida.measurementId!);
    }

    return Future.value(false);
  }
}
