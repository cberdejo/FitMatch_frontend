import 'package:fit_match/models/post.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/responsive/responsive_layout_screen.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/view_sesion_entrenamientos_screen.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';

import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/custom_button.dart';

import 'package:collection/collection.dart';
import 'package:fit_match/widget/preferences.dart';
import 'package:fit_match/widget/preferences_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreateProgramScreen extends StatefulWidget {
  final User user;
  final int? templateId; //editar
  const CreateProgramScreen({super.key, required this.user, this.templateId});

  @override
  _CreateProgramScreenState createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends State<CreateProgramScreen> {
  PlantillaPost? editingTemplate;
  final _formKey = GlobalKey<FormState>();
  final _programNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    initEditData();
  }

  void _setLoadingState(bool loading) {
    setState(() => _isLoading = loading);
  }

  Future<void> initEditData() async {
    try {
      _setLoadingState(true);
      if (widget.templateId != null) {
        PlantillaPost sesionEntrenamiento =
            await PlantillaPostsMethods().getPlantillaById(widget.templateId!);
        setState(() {
          editingTemplate = sesionEntrenamiento;
        });
        // Inicializar los controladores de texto
        _programNameController.text = editingTemplate!.templateName;
        _descriptionController.text = editingTemplate!.description ?? '';

        // Cargar imagen desde Cloudinary
        Uint8List? loadedImage =
            await _loadImageFromUrl(editingTemplate!.picture!);
        setState(() {
          _thumbnailImage = loadedImage;
        });

        // Inicializar preferencias
        _initializePreferences(editingTemplate!);
      }
    } catch (e) {
      print(e);
    } finally {
      _setLoadingState(false);
    }
  }

  Future<Uint8List?> _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Manejo de errores, por ejemplo, si la imagen no se puede cargar
        return null;
      }
    } catch (e) {
      // Manejo de excepciones, como problemas de red
      return null;
    }
  }

  void _initializePreferences(PlantillaPost editingTemplate) async {
    var sectionsMap = editingTemplate.getSectionsMap();

    selectedExperience = sectionsMap['Experiencia']?.isNotEmpty ?? false
        ? sectionsMap['Experiencia'].first
        : experienciaOptions.first.value;

    selectedEquipment = sectionsMap['Equipamiento']?.isNotEmpty ?? false
        ? sectionsMap['Equipamiento'].first
        : equipmentOptions.first.value;

    selectedDuration = sectionsMap['Duracion']?.isNotEmpty ?? false
        ? sectionsMap['Duracion'].first
        : durationOptions.first.value;

    // Reconstruir CheckboxPreference para Objetivos
    objetivosOptions = objetivosOptions.map((option) {
      return CheckboxPreference(
        title: option.title,
        value: sectionsMap['Objetivos'].contains(option.title),
      );
    }).toList();

    // Reconstruir CheckboxPreference para Intereses
    interesesOptions = interesesOptions.map((option) {
      return CheckboxPreference(
        title: option.title,
        value: sectionsMap['Disciplinas'].contains(option.title),
      );
    }).toList();

    //Inicializar las preferencias de objetivos
    selectedObjectives.clear();
    for (var option in objetivosOptions) {
      selectedObjectives[option.title] =
          sectionsMap['Objetivos']?.contains(option.title) ?? false;
    }
    // Inicializar las preferencias de disciplinas
    selectedInterests.clear();
    for (var option in interesesOptions) {
      selectedInterests[option.title] =
          sectionsMap['Disciplinas']?.contains(option.title) ?? false;
    }
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
                onPressed: () => _navigateBack(),
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
    _setLoadingState(true);

    try {
      if (_isFormValid()) {
        await _processFormSubmission();
      }
    } catch (e) {
      print(e);
      showToast(context, 'Ha ocurrido un error. Por favor, intenta de nuevo.',
          exitoso: false);
    } finally {
      _setLoadingState(false);
    }
  }

  bool _isFormValid() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    bool hasSelectedObjective = selectedObjectives.containsValue(true);
    bool hasSelectedInterest = selectedInterests.containsValue(true);

    if (!hasSelectedObjective || !hasSelectedInterest) {
      showToast(
          context, 'Por favor, selecciona al menos un objetivo y un interés.');
      return false;
    }

    return true;
  }

  Future<void> _processFormSubmission() async {
    final programName = _programNameController.text;
    final description = _descriptionController.text;
    final thumbnailImage = _thumbnailImage;

    List<Etiqueta> etiquetas = _createEtiquetas();

    if (editingTemplate != null) {
      bool hasChanges = await _hasChanges();
      if (hasChanges) {
        await _updateTemplate(
            programName, description, thumbnailImage, etiquetas);
      } else {
        navigateNext(editingTemplate!.templateId);
      }
    } else {
      await _createTemplate(
          programName, description, thumbnailImage, etiquetas);
    }
  }

  Future<bool> _hasChanges() async {
    // Comprobación inicial rápida para cambios simples y URL de imagen.
    bool hasChanges =
        _programNameController.text != editingTemplate?.templateName ||
            _descriptionController.text != editingTemplate?.description ||
            (_thumbnailImage != null && editingTemplate?.picture == null) ||
            (_thumbnailImage == null && editingTemplate?.picture != null);

    // Si ya detectamos cambios, no es necesario seguir.
    if (hasChanges) return true;

    // Comprobación de cambios en las etiquetas.
    hasChanges = hasChanges || _hasEtiquetasChanged();

    // Si aún no hemos encontrado cambios y tenemos una imagen nueva,
    // comparamos la imagen solo si la URL no ha cambiado.
    if (!hasChanges &&
        editingTemplate?.picture != null &&
        _thumbnailImage != null) {
      final Uint8List? remoteImage =
          await _loadImageFromUrl(editingTemplate!.picture!);
      // Comparar la imagen remota con la imagen actual (ambas en formato Uint8List).
      hasChanges = !listEquals(_thumbnailImage, remoteImage);
    }

    return hasChanges;
  }

  bool _hasEtiquetasChanged() {
    if (editingTemplate == null) {
      return false; // No hay plantilla previa con la cual comparar.
    }

    Map<String, List<String>> currentEtiquetasMap = _getCurrentEtiquetasMap();
    Map<String, dynamic> initialEtiquetasMap =
        editingTemplate!.getSectionsMap();

    for (var key in initialEtiquetasMap.keys) {
      List<String> initialValues =
          List<String>.from(initialEtiquetasMap[key]!.map((e) => e.toString()));

      List<String> currentValues = currentEtiquetasMap[key] ?? [];

      // Para categorías que pueden tener múltiples valores
      if (key == 'Disciplinas' || key == 'Objetivos') {
        // Comprobar si las listas son iguales, independientemente del orden
        if (!const SetEquality()
            .equals(initialValues.toSet(), currentValues.toSet())) {
          return true;
        }
      } else {
        // Para valores únicos, verificar primero si ambas listas están vacías o tienen elementos
        if (initialValues.isEmpty && currentValues.isEmpty) {
          continue; // Ambas listas están vacías, considerar como iguales
        } else if (initialValues.isEmpty || currentValues.isEmpty) {
          return true; // Una lista está vacía y la otra no, son diferentes
        } else if (initialValues.first != currentValues.first) {
          return true; // Los valores únicos no coinciden
        }
      }
    }

    // Si llegamos aquí, no hay cambios en las etiquetas.

    return false;
  }

  Map<String, List<String>> _getCurrentEtiquetasMap() {
    Map<String, List<String>> etiquetasMap = {
      'Experiencia': [selectedExperience],
      'Disciplinas': selectedInterests.keys
          .where((k) => selectedInterests[k] == true)
          .toList(),
      'Objetivos': selectedObjectives.keys
          .where((k) => selectedObjectives[k] == true)
          .toList(),
      'Equipamiento': [selectedEquipment],
      'Duracion': [selectedDuration],
    };

    return etiquetasMap;
  }

  List<Etiqueta> _createEtiquetas() {
    List<Etiqueta> etiquetas = [];

    etiquetas.addAll(_createEtiquetasFromMap(selectedObjectives, 'objectives'));
    etiquetas.addAll(_createEtiquetasFromMap(selectedInterests, 'interests'));

    etiquetas.add(Etiqueta(experience: selectedExperience));
    etiquetas.add(Etiqueta(equipment: selectedEquipment));
    etiquetas.add(Etiqueta(duration: selectedDuration));

    return etiquetas;
  }

  Future<void> _updateTemplate(String programName, String description,
      dynamic thumbnailImage, List<Etiqueta> etiquetas) async {
    PlantillaPost plantillaActualizada = PlantillaPost(
        templateId: editingTemplate!.templateId,
        userId: editingTemplate!.userId,
        templateName: programName,
        description: description,
        public: false,
        hidden: false,
        etiquetas: etiquetas);

    int templateId = editingTemplate!.templateId;
    if (plantillaActualizada != editingTemplate) {
      templateId = await PlantillaPostsMethods()
          .updatePlantilla(plantillaActualizada, thumbnailImage);
    }

    navigateNext(templateId);
  }

  Future<void> _createTemplate(String programName, String description,
      dynamic thumbnailImage, List<Etiqueta> etiquetas) async {
    int templateId = await PlantillaPostsMethods().postPlantilla(
        userId: widget.user.user_id,
        templateName: programName,
        description: description,
        picture: thumbnailImage,
        etiquetas: etiquetas);

    navigateNext(templateId);
  }

  List<Etiqueta> _createEtiquetasFromMap(Map map, String type) {
    return map.entries
        .where((element) => element.value)
        .map((e) => type == 'objectives'
            ? Etiqueta(objectives: e.key)
            : Etiqueta(interests: e.key))
        .toList();
  }

  void _navigateBack() {
    //Navigator.of(context).pop();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResponsiveLayout(
        user: widget.user,
        initialPage: 3,
      ),
    ));
  }

  void navigateNext(int templateId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewSesionEntrenamientoScreen(
        user: widget.user,
        templateId: templateId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nuevo Programa'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                _navigateBack();
              }
            },
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
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
      isLoading: _isLoading,
      text: 'Siguiente',
    );
  }
}
