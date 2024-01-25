import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_sesion_entrenamientos_screen.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:flutter/material.dart';

class InfoSesionEntrenamientoScreen extends StatefulWidget {
  final int templateId;
  final User user;
  final SesionEntrenamiento? editingSesion;

  const InfoSesionEntrenamientoScreen({
    super.key,
    this.editingSesion,
    required this.templateId,
    required this.user,
  });
  @override
  _InfoSesionEntrenamientoScreen createState() =>
      _InfoSesionEntrenamientoScreen();
}

class _InfoSesionEntrenamientoScreen
    extends State<InfoSesionEntrenamientoScreen> {
  List<EjercicioDetallados> ejercicios = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void initSesionEntrenamients() async {}

  void _addExercise() {}

  void _saveEntrenamiento() {}

  void _navigateBack() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ViewSesionEntrenamientoScreen(
              templateId: widget.templateId,
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
                  _buildNewExerciseButton(context),
                  const SizedBox(height: 16),
                  _buildSaveButton(context),
                ])));
  }

  Widget _buildEntrenamientosList(BuildContext context) {
    if (ejercicios.isEmpty) {
      return const Text(
        'No hay ejercicios todavía',
        style: TextStyle(fontSize: 18),
      );
    }
    return ListView.builder(
      itemCount: ejercicios.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(ejercicios[index].exerciseId.toString()),
        );
      },
    );
  }

  Widget _buildNewExerciseButton(BuildContext context) {
    return CustomButton(onTap: _addExercise, text: 'Añadir Ejercicio');
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(onTap: _saveEntrenamiento, text: 'OK');
  }
}
