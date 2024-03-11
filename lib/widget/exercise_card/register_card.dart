import 'dart:async';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/dialog.dart';
import 'package:fit_match/widget/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterCard extends StatefulWidget {
  final EjerciciosDetalladosAgrupados ejercicioDetalladoAgrupado;
  final int index;
  final int registerSessionId;
  final Function(SetsEjerciciosEntrada) onAddSet;
  final Function(SetsEjerciciosEntrada, RegistroSet) onDeleteSet;
  final Function(SetsEjerciciosEntrada, int) onUpdateSet;

  const RegisterCard({
    Key? key,
    required this.ejercicioDetalladoAgrupado,
    required this.index,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onUpdateSet,
    required this.registerSessionId,
  }) : super(key: key);

  @override
  _RegisterCard createState() => _RegisterCard();
}

class _RegisterCard extends State<RegisterCard> {
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

  void _showDialog(String description, BuildContext context) async {
    CustomDialog.show(
      context,
      Text(description),
      () {},
    );
  }

  List<RegistroSet> _getThisRegisterSessionSets(
      SetsEjerciciosEntrada setsEjerciciosEntrada) {
    return setsEjerciciosEntrada.registroSet!
        .where(
            (element) => element.registerSessionId == widget.registerSessionId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          ...List.generate(
              widget.ejercicioDetalladoAgrupado.ejerciciosDetallados.length,
              (i) {
            String? ordenDentroDeSet;
            if (widget.ejercicioDetalladoAgrupado.ejerciciosDetallados.length >
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
    );
  }

  Widget _buildListItem(
      BuildContext context,
      int groupIndex,
      EjercicioDetallado ejercicioDetallado,
      int exerciseIndex,
      String? ordenDentroDeSet) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
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
                  onPressed: () {
                    _showDialog(
                        ejercicioDetallado.ejercicio!.description ??
                            'Sin descripción',
                        context);
                  },
                  constraints: const BoxConstraints(),
                  alignment: Alignment.centerRight,
                ),
              ],
            ),
          ),
          //se muestra el textArea si hay texto o si se le ha dado a "nota"
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
                      text: ejercicioDetallado.notes!,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                  flex: 2,
                  child: Text(
                    'Anterior',
                    style: width < webScreenSize
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.visible,
                  ),
                ),
                Expanded(
                  flex: width < webScreenSize ? 5 : 3,
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

                // Spacer(
                //   flex: width < webScreenSize ? 5 : 3,
                // ),
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
                onDeleteSet: () => widget.onDeleteSet(setEntrada, registro),
                selectedRegisterType: ejercicioDetallado.registerTypeId,
                registroIndex: registroIndex,
                onUpdateSet: (updatedSet) {
                  widget.onUpdateSet(updatedSet, registroIndex);
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
      ),
    );
  }
}

class NumberInputField extends StatelessWidget {
  final Function(String) onFieldSubmitted;
  final String? hintText;
  final String? label;
  final TextEditingController? controller;

  const NumberInputField({
    Key? key,
    required this.onFieldSubmitted,
    this.hintText,
    this.controller,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo personalizado para el borde del campo de texto
    OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Bordes redondeados
      borderSide: BorderSide(
        color: Colors.grey.shade300, // Color del borde
      ),
    );

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        border: borderStyle,
        labelText: label,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: borderStyle.copyWith(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        hintText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        filled: true,
        fillColor: Theme.of(context).colorScheme.background,
      ),
      textAlign: TextAlign.center,
      onChanged: onFieldSubmitted,
    );
  }
}

class SetRow extends StatefulWidget {
  final SetsEjerciciosEntrada set;
  final int selectedRegisterType;
  final int registerSessionId;
  final int registroIndex;

  final Function(SetsEjerciciosEntrada) onUpdateSet;
  final Function() onDeleteSet;

  const SetRow({
    Key? key,
    required this.set,
    required this.selectedRegisterType,
    required this.onUpdateSet,
    required this.onDeleteSet,
    required this.registerSessionId,
    required this.registroIndex,
  }) : super(key: key);

  @override
  _SetRowState createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late TextEditingController repsController;
  late TextEditingController weightController;
  Timer? _debounce;
  String weightUnit = 'kg';

  @override
  void initState() {
    repsController = TextEditingController();
    weightController = TextEditingController();

    _initWeightUnit();

    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  _initWeightUnit() async {
    final system = await getSystem();
    setState(() {
      weightUnit = system == 'metrico' ? 'kg' : 'lbs';
    });
  }

  _lengthRegistroSession() {
    return widget.set.registroSet!
        .where(
            (element) => element.registerSessionId == widget.registerSessionId)
        .length;
  }

  RegistroSet get actualSet {
    return widget.set.registroSet!.elementAt(widget.registroIndex);
  }

  bool get isFirstRegisterInSet {
    if (_lengthRegistroSession() > 1) {
      var hasEarlierRegisters = widget.set.registroSet!.any((element) =>
          element.registerSessionId == widget.registerSessionId &&
          element.registerSetId != actualSet.registerSetId &&
          element.timestamp.isBefore(actualSet.timestamp));

      return !hasEarlierRegisters;
    } else {
      return true;
    }
  }

  RegistroSet? get previousToLastSet {
    // Verificar si la lista está vacía o si solo tiene un elemento
    if (widget.set.registroSet!.isEmpty || widget.set.registroSet!.length < 2) {
      return null;
    } else {
      // Filtrar los registros que no pertenecen a la sesión actual
      var filteredSets = widget.set.registroSet!
          .where((element) =>
              element.registerSessionId != widget.registerSessionId)
          .toList();

      if (filteredSets.isEmpty) {
        return null;
      } else {
        RegistroSet previousToLast = filteredSets.reduce((curr, next) =>
            curr.timestamp.isBefore(next.timestamp) ? curr : next);
        return previousToLast;
      }
    }
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
          actualSet.reps = intValue;
          break;
        case 'weight':
          actualSet.weight = doubleValue;
          break;
        case 'time':
          actualSet.time = doubleValue;
          break;
      }

      widget.onUpdateSet(widget.set);
    });
  }

  List<Widget> _buildInputFields() {
    switch (widget.selectedRegisterType) {
      case 1: // Rango de repeticiones

        repsController.text = actualSet.reps?.toString() ?? '';
        weightController.text = actualSet.weight?.toString() ?? '';
        return [
          Expanded(
            child: NumberInputField(
              hintText: previousToLastSet == null
                  ? "reps"
                  : previousToLastSet!.reps.toString(),
              controller: repsController,
              label: "reps",
              onFieldSubmitted: (value) => _updateSet(value, 'reps'),
            ),
          ),
          dash,
          Expanded(
            child: NumberInputField(
              controller: weightController,
              hintText: previousToLastSet == null
                  ? weightUnit
                  : previousToLastSet!.weight.toString(),
              label: weightUnit,
              onFieldSubmitted: (value) => _updateSet(value, 'weight'),
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          const Expanded(child: Text('AMRAP', style: TextStyle(fontSize: 16))),
        ];
      case 5: // Tiempo
        weightController.text = actualSet.time?.toString() ?? '';
        return [
          Expanded(
            child: NumberInputField(
              controller: weightController,
              label: "min",
              hintText: previousToLastSet == null
                  ? "min"
                  : previousToLastSet!.time.toString(),
              onFieldSubmitted: (value) => _updateSet(value, 'time'),
            ),
          ),
          minText,
        ];
      case 6: // Rango de tiempo
        repsController.text = actualSet.time?.toString() ?? '';
        weightController.text = actualSet.weight?.toString() ?? '';
        return [
          Expanded(
            child: NumberInputField(
              controller: repsController,
              label: "min",
              hintText: previousToLastSet == null
                  ? "min"
                  : previousToLastSet!.time.toString(),
              onFieldSubmitted: (value) => _updateSet(value, 'minTime'),
            ),
          ),
          dash,
          Expanded(
            child: NumberInputField(
              controller: weightController,
              label: "min",
              hintText: previousToLastSet == null
                  ? weightUnit
                  : previousToLastSet!.weight.toString(),
              onFieldSubmitted: (value) => _updateSet(value, 'maxTime'),
            ),
          ),
          minText,
        ];
      default: // Por defecto, solo repeticiones
        repsController.text = actualSet.reps.toString();
        weightController.text = actualSet.weight?.toString() ?? '';

        return [
          Expanded(
            child: NumberInputField(
              label: "reps",
              hintText: previousToLastSet == null
                  ? "reps"
                  : previousToLastSet!.reps.toString(),
              controller: repsController,
              onFieldSubmitted: (value) => _updateSet(value, 'reps'),
            ),
          ),
          dash,
          Expanded(
              child: NumberInputField(
            label: weightUnit,
            hintText: previousToLastSet == null
                ? weightUnit
                : previousToLastSet!.weight.toString(),
            controller: weightController,
            onFieldSubmitted: (value) => _updateSet(value, 'weight'),
          ))
        ];
    }
  }

  List<Widget> _buildExpectedInputFields() {
    switch (widget.selectedRegisterType) {
      case 1: // Rango de repeticiones

        return [
          Expanded(
            child: Text(
              "${widget.set.minReps?.toString() ?? '_'}-${widget.set.maxReps?.toString() ?? '_'} reps",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          const Expanded(
            child: Text('AMRAP',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16)),
          ),
        ];
      case 5: // Tiempo

        return [
          Expanded(
            child: Text(
              "${widget.set.time?.toString() ?? '_'} min",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          minText,
        ];
      case 6: // Rango de tiempo

        return [
          Expanded(
            child: Text(
              "${widget.set.maxTime?.toString() ?? '_'}-${widget.set.maxTime?.toString() ?? '_'} min",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
      default: // Por defecto, solo repeticiones

        return [
          Expanded(
            child: Text(
              "${widget.set.reps?.toString() ?? '_'} reps",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
    }
  }

  List<Widget> _buildLastSessionInputFields() {
    if (previousToLastSet == null) {
      return [
        const Expanded(
          child: Text("  _", style: TextStyle(fontSize: 16)),
        ),
      ];
    }

    //  que previousToLastSet no es nulo
    switch (widget.selectedRegisterType) {
      case 1: // Rango de repeticiones
        return [
          Expanded(
            child: Text(
              "${previousToLastSet!.reps?.toString() ?? '_'} reps x ${previousToLastSet!.weight?.toString() ?? '_'} weightUnit",
              overflow: TextOverflow.clip,
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          const Expanded(
            child: Text(
              'AMRAP',
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
      case 5: // Tiempo
        return [
          Expanded(
            child: Text(
              "${previousToLastSet!.time?.toString() ?? '_'} min",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
      case 6: // Rango de tiempo
        return [
          Expanded(
            child: Text(
              "${previousToLastSet!.time?.toString() ?? '_'} min x ${widget.set.maxTime?.toString() ?? '_'} weightUnit",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
      default: // Por defecto, solo repeticiones
        return [
          Expanded(
            child: Text(
              "${previousToLastSet!.reps?.toString() ?? '_'} reps x ${previousToLastSet!.weight?.toString() ?? '_'} weightUnit",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ];
    }
  }

  Widget _buildSetRowItem() {
    double width = MediaQuery.of(context).size.width;

    List<Widget> inputFields = _buildInputFields();
    List<Widget> expectedInputFields = _buildExpectedInputFields();
    List<Widget> lastSessionInputFields = _buildLastSessionInputFields();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text('${widget.set.setOrder}',
                style: const TextStyle(fontSize: 16))),
        Expanded(
          flex: 2,
          child: Row(children: expectedInputFields),
        ),
        Expanded(
          flex: 2,
          child: Center(child: Row(children: lastSessionInputFields)),
        ),
        Expanded(
          flex: width < webScreenSize ? 4 : 2,
          child: Row(children: inputFields),
        ),
        Expanded(
          child: Wrap(
            children: [
              IconButton(
                onPressed: null,
                icon:
                    Icon(Icons.videocam, color: Theme.of(context).primaryColor),
              ),
              if (_lengthRegistroSession() > 1 && !isFirstRegisterInSet)
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
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: _buildSetRowItem(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
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
