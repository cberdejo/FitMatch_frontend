import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/screens/client/training/info_sesion_entrenamientos_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
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
  }

  void initSesionEntrenamients() async {
    try {
      // Obtener nuevos posts.
      var sesiones = await SesionEntrenamientoMethods()
          .getSesionesEntrenamientoByTemplateId(widget.templateId);

      // Actualizar la lista de posts y el estado si el componente sigue montado.
      if (mounted) {
        this.sesiones = sesiones;
      }
    } catch (e) {
      print(e);
    }
  }

  void _navigateNewSesion() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => InfoSesionEntrenamientoScreen(
              user: widget.user,
              templateId: widget.templateId,
            )));
  }

  void _saveEntrenamientos() {}

  void _navigateBack() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ResponsiveLayout(
              user: widget.user,
            )));
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
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEntrenamientosList(context),
                  const SizedBox(height: 16),
                  _buildNewSesionButton(context),
                  const SizedBox(height: 16),
                  _buildSaveButton(context),
                ])));
  }

  Widget _buildEntrenamientosList(BuildContext context) {
    if (sesiones.isEmpty) {
      return const Text(
        'No hay sesiones de entrenamiento todavía',
        style: TextStyle(fontSize: 18),
      );
    }
    return ListView.builder(
      itemCount: sesiones.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(sesiones[index].sessionName),
        );
      },
    );
  }

  Widget _buildNewSesionButton(BuildContext context) {
    return CustomButton(
        onTap: _navigateNewSesion, text: 'Crear sesión de entrenamiento');
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(onTap: _saveEntrenamientos, text: 'Guardar');
  }
}
