import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/info_sesion_entrenamientos_screen.dart';
import 'package:fit_match/services/sesion_entrenamientos_service.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:flutter/material.dart';

class ViewSesionEntrenamientoScreen extends StatefulWidget {
  final User user;
  final int templateId;

  const ViewSesionEntrenamientoScreen({
    super.key,
    required this.user,
    required this.templateId,
  });
  @override
  _ViewSesionEntrenamientoScreen createState() =>
      _ViewSesionEntrenamientoScreen();
}

class _ViewSesionEntrenamientoScreen
    extends State<ViewSesionEntrenamientoScreen> {
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

  void _deleteSesion(SesionEntrenamiento sesion) async {
    await SesionEntrenamientoMethods()
        .deleteSesionEntrenamiento(sesion.sessionId);
    showToast(context, 'Sesion eliminada', exitoso: true);
    initSesionEntrenamientos();
  }

  Future<void> _navigateNewSesion(
      SesionEntrenamiento sesionEntrenamiento) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => InfoSesionEntrenamientoScreen(
        user: widget.user,
        templateId: widget.templateId,
        sessionId: sesionEntrenamiento.sessionId,
      ),
    ))
        .then((result) {
      if (result == true) {
        initSesionEntrenamientos();
      }
    });
  }

  void _createSession() async {
    try {
      SesionEntrenamiento sesionEntrenamiento =
          await SesionEntrenamientoMethods().createSesionEntrenamiento(
              templateId: widget.templateId,
              order: sesiones.length + 1,
              sessionName: 'Día ${sesiones.length + 1}');

      _navigateNewSesion(sesionEntrenamiento);
    } catch (e) {
      showToast(context, e.toString(), exitoso: false);
    }
  }

  void _saveEntrenamientos() {}

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones de Entrenamiento'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            _navigateBack();
          },
        ),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEntrenamientosList(context),
                  const SizedBox(height: 16),
                  _buildNewSesionButton(context),
                  const SizedBox(height: 16),
                  _buildSaveButton(context),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildEntrenamientosList(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (sesiones.isEmpty) {
      return const Text(
        'No hay sesiones de entrenamiento todavía',
        style: TextStyle(fontSize: 18),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: sesiones.length,
      itemBuilder: (context, index) {
        if (width < webScreenSize) {
          return Dismissible(
            key: Key(sesiones[index].toString()),
            background: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Row(children: [Icon(Icons.delete), Text('Eliminar')]),
              ),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                _deleteSesion(sesiones[index]);
              }
            },
            child: _buildListItem(context, index),
          );
        } else {
          return _buildListItem(context, index);
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateNewSesion(sesiones[index]),
        child: Card(
          child: ListTile(
            title: Text(sesiones[index].sessionName),
            trailing: _buildPopupMenuButton(context, sesiones[index]),
          ),
        ),
      ),
    );
  }

  _buildPopupMenuButton(BuildContext context, SesionEntrenamiento sesion) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'Editar',
          child: Text('editar'),
        ),
        const PopupMenuItem(
          value: 'Eliminar',
          child: Text('eliminar'),
        ),
      ],
      onSelected: (value) => _handleMenuItemSelected(value, sesion),
    );
  }

  void _handleMenuItemSelected(String value, SesionEntrenamiento sesion) {
    switch (value) {
      case 'Editar':
        _navigateNewSesion(sesion);
        break;
      case 'Eliminar':
        _deleteSesion(sesion);
    }
  }

  Widget _buildNewSesionButton(BuildContext context) {
    return CustomButton(
        onTap: _createSession, text: 'Crear sesión de entrenamiento');
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(onTap: _saveEntrenamientos, text: 'Guardar');
  }
}
