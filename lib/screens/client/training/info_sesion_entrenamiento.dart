import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:fit_match/widget/dialog.dart';
import 'package:fit_match/widget/show_modal_bottom_sheet.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:flutter/material.dart';

class ExerciseCreationScreen extends StatefulWidget {
  @override
  _ExerciseCreationScreenState createState() => _ExerciseCreationScreenState();
}

class _ExerciseCreationScreenState extends State<ExerciseCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Programa de Entrenamiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFieldInput(
              textEditingController: _titleController,
              hintText: 'Título del Programa',
              textInputType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextFieldInput(
              textEditingController: _instructionsController,
              hintText: 'Instrucciones',
              textInputType: TextInputType.multiline,
              maxLine: true,
            ),
            const SizedBox(height: 16),
            CustomButton(
              onTap: () => _showAddExerciseDialog(context),
              text: 'Añadir Ejercicio',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    if (width > webScreenSize) {
      // Usar una constante para este valor si es necesario
      CustomDialog.show(context, _buildAddExerciseContent(),
          () => Navigator.of(context).pop());
    } else {
      CustomShowModalBottomSheet.show(context, _buildAddExerciseContent());
    }
  }

  Widget _buildAddExerciseContent() {
    // Aquí construyes el contenido que se mostrará en el diálogo/modal
    return Container(
        // Tu contenido aquí
        );
  }
}
