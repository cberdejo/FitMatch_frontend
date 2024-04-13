import 'dart:async';
import 'package:expandable_text/expandable_text.dart';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/expandable_text.dart';
import 'package:fit_match/widget/imagen_detailed.dart';
import 'package:fit_match/widget/number_input_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCard extends StatefulWidget {
  final EjerciciosDetalladosAgrupados ejercicioDetalladoAgrupado;
  final int index;
  final int registerSessionId;
  final String system;
  final Function(SetsEjerciciosEntrada) onAddSet;
  final Function(SetsEjerciciosEntrada, RegistroSet) onDeleteSet;
  final Function(RegistroSet) onUpdateSet;

  const RegisterCard({
    Key? key,
    required this.ejercicioDetalladoAgrupado,
    required this.index,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onUpdateSet,
    required this.registerSessionId,
    this.system = "metrico",
  }) : super(key: key);

  @override
  RegisterCardState createState() => RegisterCardState();
}

class RegisterCardState extends State<RegisterCard> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    initControladores();
  }

  void initControladores() {
    widget.ejercicioDetalladoAgrupado.ejerciciosDetallados
        .asMap()
        .forEach((index, ejercicio) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getThisRegisterSessionSets(SetsEjerciciosEntrada setsEjerciciosEntrada) {
    List<RegistroSet> sets = setsEjerciciosEntrada.registroSet!
        .where(
            (element) => element.registerSessionId == widget.registerSessionId)
        .toList();
    return sets;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            ...List.generate(
                widget.ejercicioDetalladoAgrupado.ejerciciosDetallados.length,
                (i) {
              String? ordenDentroDeSet;
              if (widget
                      .ejercicioDetalladoAgrupado.ejerciciosDetallados.length >
                  1) {
                ordenDentroDeSet = getExerciseLetter(i);
              }

              return Column(
                children: [
                  _buildListItem(
                      context,
                      widget.index,
                      widget.ejercicioDetalladoAgrupado.ejerciciosDetallados[i],
                      i,
                      ordenDentroDeSet),
                  if (i <
                      widget.ejercicioDetalladoAgrupado.ejerciciosDetallados
                              .length -
                          1)
                    const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
      BuildContext context,
      int groupIndex,
      EjercicioDetallado ejercicioDetallado,
      int exerciseIndex,
      String? ordenDentroDeSet) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        ListTile(
          leading: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${groupIndex + 1} ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (ordenDentroDeSet != null)
                  TextSpan(
                    text: '$ordenDentroDeSet ',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )
              ],
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  ejercicioDetallado.ejercicio?.name ??
                      'Ejercicio no especificado',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () async {
                  String? iconName =
                      ejercicioDetallado.ejercicio?.muscleGroupId != null
                          ? await getIconNameByMuscleGroupId(
                              ejercicioDetallado.ejercicio!.muscleGroupId, [])
                          : null;

                  showDialogExerciseInfo(
                      context,
                      ejercicioDetallado.ejercicio!.name,
                      ejercicioDetallado.ejercicio!.description,
                      iconName,
                      ejercicioDetallado.ejercicio!.video);
                },
                constraints: const BoxConstraints(),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ),
        ...[
          if (ejercicioDetallado.notes != null)
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.all(10.0),
              color: Theme.of(context).colorScheme.background,
              child: Wrap(
                children: [
                  const Text("notas: "),
                  ExpandableText(
                    ejercicioDetallado.notes!,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall,
                    expandText: 'mostrar más',
                    collapseText: 'mostrar menos',
                  ),
                ],
              ),
            ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  'Set',
                  style: width < webScreenSize
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Objetivo',
                  style: width < webScreenSize
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Anterior',
                  style: width < webScreenSize
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.visible,
                ),
              ),
              Expanded(
                flex: 4,
                child: Center(
                  child: Text(
                    'Entrada',
                    style: width < webScreenSize
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        ...ejercicioDetallado.setsEntrada!.expand((setEntrada) {
          List<RegistroSet> registrosPorSet =
              _getThisRegisterSessionSets(setEntrada);
          int setIndex = ejercicioDetallado.setsEntrada!.indexOf(setEntrada);
          return registrosPorSet.asMap().entries.map((entry) {
            int registroIndex = entry.key;
            RegistroSet registro = entry.value;

            return SetRow(
              set: setEntrada,
              registerSessionId: widget.registerSessionId,
              system: widget.system,
              onDeleteSet: () => widget.onDeleteSet(setEntrada, registro),
              selectedRegisterType: ejercicioDetallado.registerTypeId,
              actualRegistroSet: registro,
              onUpdateSet: (registroSet) {
                widget.onUpdateSet(registroSet);
              },
            );
          }).toList();
        }).toList(),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () =>
              {widget.onAddSet(ejercicioDetallado.setsEntrada!.last)},
          child: const Text("+ añadir set"),
        ),
      ],
    );
  }
}

class SetRow extends StatefulWidget {
  final SetsEjerciciosEntrada set;
  final int selectedRegisterType;
  final int registerSessionId;
  final RegistroSet actualRegistroSet;
  final String system;

  final Function(RegistroSet) onUpdateSet;
  final Function() onDeleteSet;

  const SetRow({
    Key? key,
    required this.set,
    required this.selectedRegisterType,
    required this.onUpdateSet,
    required this.onDeleteSet,
    required this.registerSessionId,
    required this.actualRegistroSet,
    required this.system,
  }) : super(key: key);

  @override
  SetRowState createState() => SetRowState();
}

class SetRowState extends State<SetRow> {
  late TextEditingController repsController;
  late TextEditingController weightController;
  Timer? _debounce;
  String weightUnit = '';
  // XFile? videoFile; // Para almacenar el video seleccionado

  @override
  void initState() {
    repsController = TextEditingController();
    weightController = TextEditingController();

    weightUnit = widget.system == "metrico" ? 'kg' : 'lbs';
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

//Devuelve cuantos registro sets hay para un set de entrada
  _lengthRegistroSession() {
    return widget.set.registroSet!
        .where(
            (element) => element.registerSessionId == widget.registerSessionId)
        .length;
  }

  // void _pickVideo() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
  //   if (video != null) {
  //     setState(() {
  //       videoFile = video;
  //     });
  //   }
  // }

  // void _viewVideo() {
  //   Navigator.of(context).push(MaterialPageRoute(
  //     builder: (context) => VideoDetailScreen(
  //       videoPath: videoFile!.path,
  //       onDeleteVideo: () {
  //         setState(() {
  //           videoFile = null;
  //         });
  //       },
  //     ),
  //   ));
  // }

  //Devuelve true en caso de que exista un registro en el set en una sesión de registro anterior
  bool get isFirstRegisterInSet {
    if (_lengthRegistroSession() > 1) {
      var hasEarlierRegisters = widget.set.registroSet!.any((element) =>
          element.registerSessionId == widget.registerSessionId &&
          element.registerSetId != widget.actualRegistroSet.registerSetId &&
          element.timestamp.isBefore(widget.actualRegistroSet.timestamp));

      return !hasEarlierRegisters;
    } else {
      return true;
    }
  }

//Obtener el anterior registro set del set de entrada
  RegistroSet? get previousToLastSet {
    // Filtrar los registros que no pertenecen al registro de sesión actual
    var filteredSets = widget.set.registroSet
        ?.where(
            (element) => element.registerSessionId != widget.registerSessionId)
        .toList();

    // Verificar si después de filtrar, la lista no está vacía
    if (filteredSets == null || filteredSets.isEmpty) {
      return null;
    }

    // Ordenar los registros por fecha en orden ascendente
    filteredSets.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Obtener el penúltimo elementom ( es decir, el primero de filteredSets )
    RegistroSet previousToLast = filteredSets[0];

    // Convertir el peso si es necesario
    if (previousToLast.weight != null) {
      previousToLast.weight = widget.system == "metrico"
          ? previousToLast.weight
          : fromKgToLbs(previousToLast.weight!);
    }

    return previousToLast;
  }

  Widget dash = const SizedBox(
    width: 12,
    child: Text(
      '-',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
  );

  Widget minText = const SizedBox(
    width: 36,
    child: Text(
      'min',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16),
    ),
  );

  void _updateSet(String value, String field) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      int? intValue = int.tryParse(value);
      double? doubleValue = double.tryParse(value);

      switch (field) {
        case 'reps':
          widget.actualRegistroSet.reps = intValue;
          break;
        case 'weight':
          widget.actualRegistroSet.weight = doubleValue;
          break;
        case 'time':
          widget.actualRegistroSet.time = doubleValue;
          break;
      }

      //Solo se actualiza si lo valores no son nulos
      switch (widget.selectedRegisterType) {
        case 2: // Rango de repeticiones
          widget.onUpdateSet(widget.actualRegistroSet);

          break;
        case 4: // AMRAP
          //no hay que actualizar nada
          break;
        case 5: // Tiempo
          widget.onUpdateSet(widget.actualRegistroSet);

          break;
        case 6: //Rango de tiempo
          widget.onUpdateSet(widget.actualRegistroSet);

          break;
        default:
          widget.onUpdateSet(widget.actualRegistroSet);

          break;
      }
    });
  }

  String transformWeightIntoLbs(num? weight) {
    if (weight == null) {
      return '';
    }

    if (widget.system == "metrico") {
      return weight.toString();
    } else if (widget.system == "imperial") {
      return fromKgToLbs(weight).toString();
    }

    return '';
  }

  List<Widget> _buildInputFields() {
    switch (widget.selectedRegisterType) {
      case 2: // Objetivo de repeticiones

        repsController.text = widget.actualRegistroSet.reps?.toString() ?? '';
        weightController.text =
            transformWeightIntoLbs(widget.actualRegistroSet.weight);
        return [
          Expanded(
            child: DoubleInputField(
              hintText: "reps",
              controller: repsController,
              label: "reps",
              onFieldSubmitted: (value) => _updateSet(value, 'reps'),
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          const Expanded(child: Text('AMRAP', style: TextStyle(fontSize: 16))),
        ];
      case 5: // Tiempo
        weightController.text = widget.actualRegistroSet.time?.toString() ?? '';
        return [
          Expanded(
            child: DoubleInputField(
              controller: weightController,
              label: "min",
              hintText: "min",
              onFieldSubmitted: (value) => _updateSet(value, 'time'),
            ),
          ),
          minText,
        ];
      case 6: // Rango de tiempo
        repsController.text = widget.actualRegistroSet.time?.toString() ?? '';
        weightController.text =
            transformWeightIntoLbs(widget.actualRegistroSet.weight);
        return [
          Expanded(
            child: DoubleInputField(
              controller: repsController,
              label: "min",
              hintText: "min",
              onFieldSubmitted: (value) => _updateSet(value, 'time'),
            ),
          ),
          minText,
          dash,
          Expanded(
            child: DoubleInputField(
              controller: weightController,
              label: weightUnit,
              hintText: weightUnit,
              onFieldSubmitted: (value) => _updateSet(value, 'weight'),
            ),
          ),
        ];
      default: // Por defecto, solo repeticiones y peso
        repsController.text = widget.actualRegistroSet.reps?.toString() ?? '';
        weightController.text =
            transformWeightIntoLbs(widget.actualRegistroSet.weight);
        return [
          Expanded(
            child: DoubleInputField(
              label: "reps",
              hintText: "reps",
              controller: repsController,
              onFieldSubmitted: (value) => _updateSet(value, 'reps'),
            ),
          ),
          dash,
          Expanded(
              child: DoubleInputField(
            label: weightUnit,
            hintText: weightUnit,
            controller: weightController,
            onFieldSubmitted: (value) => _updateSet(value, 'weight'),
          ))
        ];
    }
  }

  List<Widget> _buildExpectedInputFields(double width) {
    switch (widget.selectedRegisterType) {
      case 1: // Rango de repeticiones

        return [
          Text(
            "${widget.set.minReps?.toString() ?? ''} - ${widget.set.maxReps?.toString() ?? ''} ${(widget.set.minReps == null && widget.set.maxReps == null) ? '' : 'reps'}",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          Text(
            'AMRAP',
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 5: // Tiempo

        return [
          Text(
            "${widget.set.time?.toString() ?? ''} min",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 6: // Rango de tiempo

        return [
          Text(
            "${widget.set.maxTime?.toString() ?? ''} - ${widget.set.maxTime?.toString() ?? '_'} min",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      default: // Por defecto, solo repeticiones

        return [
          Text(
            "${widget.set.reps?.toString() ?? ''} reps",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
    }
  }

  List<Widget> _buildLastSessionInputFields(double width) {
    if (previousToLastSet == null) {
      return [
        Text('N/A',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Colors.grey, fontSize: width > webScreenSize ? 16 : 12)),
      ];
    }

    //  que previousToLastSet no es nulo
    switch (widget.selectedRegisterType) {
      case 2:
        return [
          Text(
            "${previousToLastSet!.reps.toString()} reps ",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          Text(
            'AMRAP',
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 5: // Tiempo
        return [
          Text(
            "${previousToLastSet!.time.toString()} min",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      case 6: // Rango de tiempo
        return [
          Text(
            "${previousToLastSet!.time.toString()} min x ${previousToLastSet!.weight.toString()} $weightUnit",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
      default: // Por defecto, solo repeticiones
        return [
          Text(
            "${previousToLastSet!.reps.toString()} reps x ${previousToLastSet!.weight.toString()} $weightUnit",
            style: TextStyle(
              fontSize: width > webScreenSize ? 16 : 12,
            ),
          ),
        ];
    }
  }

  Widget _buildSetRowItem() {
    double width = MediaQuery.of(context).size.width;

    List<Widget> inputFields = _buildInputFields();
    List<Widget> expectedInputFields = _buildExpectedInputFields(width);
    List<Widget> lastSessionInputFields = _buildLastSessionInputFields(width);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            flex: 1,
            child: Text('${widget.set.setOrder}',
                style: const TextStyle(fontSize: 16))),
        Flexible(
          flex: 2,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: expectedInputFields,
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: lastSessionInputFields)),
        ),
        Expanded(
          flex: 4,
          child: Center(child: Row(children: inputFields)),
        ),
        if (_lengthRegistroSession() > 1 && !isFirstRegisterInSet)
          Expanded(
            child: Wrap(
              children: [
                // IconButton(
                //   onPressed: videoFile == null ? _pickVideo : _viewVideo,
                //   icon: Icon(
                //       videoFile == null ? Icons.videocam : Icons.play_circle_fill,
                //       color: Theme.of(context).colorScheme.onPrimaryContainer),
                // ),

                IconButton(
                  onPressed: () => widget.onDeleteSet(),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!(_lengthRegistroSession() > 1 && !isFirstRegisterInSet)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
        child: _buildSetRowItem(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
        child: Dismissible(
          key: ValueKey('set_$widget.set.setId}_${DateTime.now()}'),
          onDismissed: (_) => widget.onDeleteSet(),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return widget.set.registroSet!.length > 1;
          },
          child: _buildSetRowItem(),
        ),
      );
    }
  }
}
