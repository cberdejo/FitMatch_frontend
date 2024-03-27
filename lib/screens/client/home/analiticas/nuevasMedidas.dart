import 'package:fit_match/models/medidas.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/medidas_service.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/dialog.dart';
import 'package:fit_match/widget/edit_Icon.dart';
import 'package:fit_match/widget/number_input_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NuevaMedidaScreen extends StatefulWidget {
  final User user;

  const NuevaMedidaScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<NuevaMedidaScreen> createState() => _NuevaMedidaScreen();
}

class _NuevaMedidaScreen extends State<NuevaMedidaScreen> {
  bool isLoading = true;
  List<Medidas> medidas = [];
  final List<XFile> _images = [];

  final _weightController = TextEditingController();

  final _waistController = TextEditingController();
  final _neckController = TextEditingController();

  final _chestController = TextEditingController();
  final _shoulderController = TextEditingController();

  final _leftLegController = TextEditingController();
  final _rightLegController = TextEditingController();

  final _leftCalfController = TextEditingController();
  final _rightCalfController = TextEditingController();

  final _leftArmController = TextEditingController();
  final _rightArmController = TextEditingController();

  final _leftForearmController = TextEditingController();
  final _rightForearmController = TextEditingController();

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _images.addAll(selectedImages);
      });
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _leftLegController.dispose();
    _rightLegController.dispose();
    _leftCalfController.dispose();
    _rightCalfController.dispose();
    _leftArmController.dispose();
    _rightArmController.dispose();
    _leftForearmController.dispose();
    _rightForearmController.dispose();
    super.dispose();
  }

  bool _checkIfAllControllersAreEmpty() {
    if (_weightController.text.isEmpty &&
        _waistController.text.isEmpty &&
        _neckController.text.isEmpty &&
        _chestController.text.isEmpty &&
        _shoulderController.text.isEmpty &&
        _leftLegController.text.isEmpty &&
        _rightLegController.text.isEmpty &&
        _leftCalfController.text.isEmpty &&
        _rightCalfController.text.isEmpty &&
        _leftArmController.text.isEmpty &&
        _rightArmController.text.isEmpty &&
        _leftForearmController.text.isEmpty &&
        _rightForearmController.text.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Medidas _getMedidaByControllers() {
    return Medidas(
      userId: widget.user.user_id as int,
      weight: _weightController.text.isEmpty
          ? null
          : double.tryParse(_weightController.text),
      waist: _waistController.text.isEmpty
          ? null
          : double.tryParse(_waistController.text),
      neck: _neckController.text.isEmpty
          ? null
          : double.tryParse(_neckController.text),
      chest: _chestController.text.isEmpty
          ? null
          : double.tryParse(_chestController.text),
      shoulders: _shoulderController.text.isEmpty
          ? null
          : double.tryParse(_shoulderController.text),
      upperLeftLeg: _leftLegController.text.isEmpty
          ? null
          : double.tryParse(_leftLegController.text),
      upperRightLeg: _rightLegController.text.isEmpty
          ? null
          : double.tryParse(_rightLegController.text),
      leftCalve: _leftCalfController.text.isEmpty
          ? null
          : double.tryParse(_leftCalfController.text),
      rightCalve: _rightCalfController.text.isEmpty
          ? null
          : double.tryParse(_rightCalfController.text),
      leftArm: _leftArmController.text.isEmpty
          ? null
          : double.tryParse(_leftArmController.text),
      rightArm: _rightArmController.text.isEmpty
          ? null
          : double.tryParse(_rightArmController.text),
      leftForearm: _leftForearmController.text.isEmpty
          ? null
          : double.tryParse(_leftForearmController.text),
      rightForearm: _rightForearmController.text.isEmpty
          ? null
          : double.tryParse(_rightForearmController.text),
      timestamp: DateTime
          .now(), // Asumiendo que quieres establecer la fecha actual al crear una nueva medida
    );
  }

  _submitForm() async {
    //Si hay al menos un campo vacio toast de error si no se crea la medicion
    if (_checkIfAllControllersAreEmpty()) {
      showToast(context, "Rellena al menos un campo", exitoso: false);
    } else {
      Medidas medidas = _getMedidaByControllers();
      List<Uint8List>? imagesBytes = [];

      if (_images != null) {
        for (XFile img in _images) {
          Uint8List imgBytes = await img.readAsBytes();
          imagesBytes.add(imgBytes);
        }
      }

      MedidasMethods().createMedidas(medidas: medidas, pictures: imagesBytes);
      showToast(context, "Medidas añaddias!", exitoso: true);
      Navigator.pop(context, true);
    }
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estás seguro?'),
        content: const Text('Se eliminará todo el progreso.'),
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
      Navigator.of(context).pop();
    }

    return Future.value(
        false); // Evita que el botón de retroceso cierre la pantalla automáticamente.
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Añadir mediciones",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onWillPop(context),
        ),
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: width < webScreenSize
              ? Column(
                  children: [
                    buildDateTitle(),
                    const SizedBox(height: 16.0),
                    ...buildForm(),
                    const SizedBox(height: 16.0),
                    buildSubmitButton(),
                  ],
                )
              : Column(
                  children: [
                    buildDateTitle(),
                    const SizedBox(height: 16.0),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: buildForm(),
                    ),
                    const SizedBox(height: 16.0),
                    buildSubmitButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildDateTitle() {
    return Text(
      DateFormat.yMMMMd('es_ES').format(DateTime.now()),
      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }

  List<Widget> buildForm() {
    return [
      buildPictures(),
      const SizedBox(height: 16.0),
      buildMeasurements(),
    ];
  }

  Widget buildSubmitButton() {
    return GestureDetector(
      onTap: () => _submitForm(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          constraints: const BoxConstraints(maxWidth: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_box_outlined,
                size: 30,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              Text(
                "Añadir nuevas medidas",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMeasurements() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Medidas",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _showMedidasInfo(),
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text(
              "Rellena las medidas que consideres necesarias para su seguimiento"),
          const SizedBox(height: 16.0),
          buildMeasurementsList(),
        ],
      ),
    );
  }

  Widget infoMediciones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          guideSection("Peso",
              "Utiliza una balanza. Párate descalzo, cuerpo recto. Mejor en ayunas o condiciones consistentes."),
          guideSection("Cintura",
              "Mide la parte más estrecha de tu cintura, por encima del ombligo sin apretar la cinta."),
          guideSection("Cuello",
              "Alrededor de la base del cuello, donde comienza el torso, sin apretar."),
          guideSection("Pecho",
              "Bajo las axilas, parte más ancha, cinta nivelada y firme."),
          guideSection("Hombros",
              "Del borde de un hombro al otro, por la parte más ancha."),
          guideSection("Pierna (Izq/Der)",
              "Alrededor del muslo, parte más ancha cerca de la ingle."),
          guideSection("Pantorrilla (Izq/Der)",
              "Parte más ancha de la pantorrilla, estando de pie."),
          guideSection("Brazo (Izq/Der)",
              "Parte más gruesa del bíceps, brazo relajado o doblado a 90 grados."),
          guideSection("Antebrazo (Izq/Der)", "Parte más ancha del antebrazo."),
        ],
      ),
    );
  }

  Widget guideSection(String title, String description) {
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

  void _showMedidasInfo() {
    CustomDialog.show(
      context,
      infoMediciones(),
      () {
        print('Diálogo cerrado');
      },
    );
  }

  Widget buildMeasurementsList() {
    String weightSystem = widget.user.system == 'metrico' ? 'kg' : 'lbs';
    String heightSystem = widget.user.system == 'metrico' ? 'cm' : 'in';

    List<Widget> doubleDivider = [
      Divider(
        color: Theme.of(context).colorScheme.primary,
      ),
      Divider(
        color: Theme.of(context).colorScheme.primary,
      ),
    ];
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics:
              NeverScrollableScrollPhysics(), // To work inside SingleChildScrollView
          crossAxisCount: 2,
          childAspectRatio: 4, // Adjusts the aspect ratio of the grid tiles
          crossAxisSpacing: 4, // Horizontal space between tiles
          mainAxisSpacing: 4, // Vertical space between tiles
          children: [
            DoubleInputField(
                controller: _weightController,
                label: "Peso ($weightSystem)",
                hintText: weightSystem),
            Container(),
            ...doubleDivider,
            DoubleInputField(
                controller: _waistController,
                label: "Cintura ($heightSystem)",
                hintText: heightSystem),
            DoubleInputField(
                controller: _neckController,
                label: "Cuello ($heightSystem)",
                hintText: heightSystem),
            ...doubleDivider,
            DoubleInputField(
                controller: _chestController,
                label: "Pecho ($heightSystem)",
                hintText: heightSystem),
            DoubleInputField(
                controller: _shoulderController,
                label: "Hombros ($heightSystem)",
                hintText: "cm"),
            ...doubleDivider,
            DoubleInputField(
                controller: _leftLegController,
                label: "Pierna Izq ($heightSystem)",
                hintText: "cm"),
            DoubleInputField(
                controller: _rightLegController,
                label: "Pierna Der ($heightSystem)",
                hintText: "cm"),
            ...doubleDivider,
            DoubleInputField(
                controller: _leftCalfController,
                label: "Pantorrilla Izq ($heightSystem)",
                hintText: "cm"),
            DoubleInputField(
                controller: _rightCalfController,
                label: "Pantorrilla Der ($heightSystem)",
                hintText: "cm"),
            ...doubleDivider,
            DoubleInputField(
                controller: _leftArmController,
                label: "Brazo Izq ($heightSystem)",
                hintText: "cm"),
            DoubleInputField(
                controller: _rightArmController,
                label: "Brazo Der ($heightSystem)",
                hintText: "cm"),
            ...doubleDivider,
            DoubleInputField(
                controller: _leftForearmController,
                label: "Antebrazo Izq ($heightSystem)",
                hintText: "cm"),
            DoubleInputField(
                controller: _rightForearmController,
                label: "Antebrazo Der ($heightSystem)",
                hintText: "cm"),
          ],
        ),
      ],
    );
  }

  Widget buildPictures() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(children: [
        const Text(
          "Cambios visuales",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        const Text(
            "Selecciona imagenes de tu físico para posterior comparación"),
        const SizedBox(height: 16.0),
        buildMultiplePictureSelectores(),
      ]),
    );
  }

  Widget buildMultiplePictureSelectores() {
    double width = MediaQuery.of(context).size.width;
    double imageSize = width < webScreenSize ? 100 : 150;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.add_a_photo),
          label: const Text("Añadir imágenes"),
        ),
        const SizedBox(height: 16.0),
        Wrap(
          spacing: 8.0, // Espacio horizontal entre las imágenes
          runSpacing: 4.0, // Espacio vertical entre las imágenes
          children: _images.asMap().entries.map((entry) {
            int index = entry.key;
            XFile image = entry.value;

            return Stack(
              alignment: Alignment.topRight,
              children: [
                FutureBuilder<Uint8List>(
                  future: image.readAsBytes(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      return InkWell(
                        onTap: () {
                          // Lógica para visualizar la imagen en pantalla completa
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ImageDetailScreen(
                                      imageData: snapshot.data!)));
                        },
                        child: Image.memory(
                          snapshot.data!,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                Positioned(
                  right: 0,
                  child: EditIcon(
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => setState(() {
                            _images.removeAt(index);
                          })),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ImageDetailScreen extends StatelessWidget {
  final Uint8List imageData;

  const ImageDetailScreen({Key? key, required this.imageData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Imagen en detalle"),
      ),
      body: Center(
        child: Image.memory(imageData),
      ),
    );
  }
}
