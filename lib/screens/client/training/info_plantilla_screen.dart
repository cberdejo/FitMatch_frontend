import 'dart:typed_data';
import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/utils/utils.dart';

import 'package:fit_match/widget/custom_button.dart';
import 'package:fit_match/widget/preferences.dart';
import 'package:fit_match/widget/preferences_section.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateProgramScreen extends StatefulWidget {
  final User user;

  const CreateProgramScreen({super.key, required this.user});

  @override
  _CreateProgramScreenState createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  final _programNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Etiquetas
  Map<String, bool> selectedObjectives = {};
  Map<String, bool> selectedInterests = {};
  String selectedExperience = 'Principiante';
  String selectedEquipment = 'Gimnasio completo';
  String selectedDuration = '30 minutos';

  Uint8List? _thumbnailImage;

  @override
  void dispose() {
    _programNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Estás seguro?'),
            content: const Text('Perderás todo el progreso.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => navigateBack(),
                child: const Text('Sí'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List im = await image.readAsBytes();
      setState(() {
        _thumbnailImage = im;
      });
    }
  }

  void _submitForm() async {
    // Verifica si el formulario es válido
    if (_formKey.currentState!.validate()) {
      bool hasSelectedObjective = selectedObjectives.containsValue(true);

      bool hasSelectedInterest = selectedInterests.containsValue(true);

      // Si no se seleccionó al menos un objetivo o un interés, muestra un error
      if (!hasSelectedObjective || !hasSelectedInterest) {
        showToast(context,
            'Por favor, selecciona al menos un objetivo y un interés.');
        return;
      }
      final programName = _programNameController.text;
      final description = _descriptionController.text;
      final thumbnailImage = _thumbnailImage;

      List<Etiqueta> etiquetas = [];

      selectedObjectives.entries.where((element) => element.value).forEach((e) {
        etiquetas.add(Etiqueta(objectives: e.key));
      });

      selectedInterests.entries.where((element) => element.value).forEach((e) {
        etiquetas.add(Etiqueta(interests: e.key));
      });

      // Añadir experiencia y equipo como etiquetas individuales
      etiquetas.add(Etiqueta(experience: selectedExperience));
      etiquetas.add(Etiqueta(equipment: selectedEquipment));

      int templateId = await PlantillaPostsMethods().postPlantilla(
          userId: widget.user.user_id,
          templateName: programName,
          description: description,
          picture: thumbnailImage,
          etiquetas: etiquetas);

      navigateNext(templateId);
    }
  }

  void navigateBack() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => ResponsiveLayout(
        user: widget.user,
        initialPage: 3,
      ),
    ));
  }

  void navigateNext(int templateId) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ResponsiveLayout(
              user: widget.user,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Programa'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildNameField(),
                const SizedBox(height: 16),
                buildDescriptionField(),
                const SizedBox(height: 16),
                buildImagePicker(),
                const SizedBox(height: 16),
                buildObjectivesSection(),
                buildInterestsSection(),
                buildExperienceSection(),
                buildEquipmentSection(),
                buildDurationSection(),
                buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNameField() {
    return TextFormField(
      controller: _programNameController,
      decoration: const InputDecoration(
        labelText: '¿Cuál es el nombre de tu programa?',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, escribe el nombre de tu programa';
        }
        return null;
      },
    );
  }

  Widget buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Escribe una descripción para tu programa*',
        border: OutlineInputBorder(),
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor escribe una descripción*';
        }
        return null;
      },
    );
  }

  Widget buildImagePicker() {
    return Column(children: [
      const Text(
        'Selecciona una miniatura para la plantilla',
      ),
      const SizedBox(height: 8),
      Stack(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: _thumbnailImage != null
                ? MemoryImage(_thumbnailImage!)
                : Image.asset('assets/images/template_placeholder.png').image,
            backgroundColor: Colors.red,
          ),
          Positioned(
            left: 80,
            child: IconButton(
                onPressed: _selectImage, icon: const Icon(Icons.add_a_photo)),
          ),
        ],
      ),
    ]);
  }

  Widget buildObjectivesSection() {
    return SectionContainer(
      title: 'Objetivos del programa',
      child: PreferencesCheckboxesWidget(
        options: objetivosOptions,
        onSelectionChanged: (selection) {
          setState(() {
            selectedObjectives = selection;
          });
        },
      ),
    );
  }

  Widget buildInterestsSection() {
    return SectionContainer(
      title: 'Deportes o disciplinas usadas en la plantilla',
      child: PreferencesCheckboxesWidget(
        options: interesesOptions,
        onSelectionChanged: (selection) {
          setState(() {
            selectedInterests = selection;
          });
        },
      ),
    );
  }

  Widget buildExperienceSection() {
    return SectionContainer(
      title: 'Nivel recomendado para rutina de entrenamiento',
      child: PreferencesRadioButtonsWidget<String>(
        options: experienciaOptions,
        initialValue: selectedExperience,
        onSelectionChanged: (selection) {
          setState(() {
            selectedExperience = selection;
          });
        },
      ),
    );
  }

  Widget buildEquipmentSection() {
    return SectionContainer(
      title: 'Equipo que será necesario para realizar la rutina',
      child: PreferencesRadioButtonsWidget<String>(
        options: equipmentOptions,
        initialValue: selectedEquipment,
        onSelectionChanged: (selection) {
          setState(() {
            selectedEquipment = selection;
          });
        },
      ),
    );
  }

  Widget buildDurationSection() {
    return SectionContainer(
        title: 'Duración aproximada de las sesiones de entrenamiento',
        child: PreferencesRadioButtonsWidget<String>(
            options: durationOptions,
            initialValue: selectedDuration,
            onSelectionChanged: (selection) {
              setState(() {
                selectedDuration = selection;
              });
            }));
  }

  Widget buildSubmitButton() {
    return CustomButton(
      onTap: _submitForm,
      text: 'Siguiente',
    );
  }
}
