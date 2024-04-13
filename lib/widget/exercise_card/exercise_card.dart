import 'dart:async';

import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/number_input_field.dart';

// import 'package:fit_match/widget/exercise_card/sets_list.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatefulWidget {
  final EjerciciosDetalladosAgrupados ejercicioDetalladoAgrupado;
  final List<TipoDeRegistro> registerTypes;
  final int index;
  final Function(int, int) onAddSet;
  final Function(int, int, int) onDeleteSet;
  final Function(int, int) onDeleteEjercicioDetalladoAgrupado;
  final Function(int, int, int, SetsEjerciciosEntrada) onUpdateSet;
  final Function(int, int, String) onEditNote;
  final Function() showReordenar;

  const ExerciseCard({
    Key? key,
    required this.ejercicioDetalladoAgrupado,
    required this.registerTypes,
    required this.index,
    required this.onDeleteEjercicioDetalladoAgrupado,
    required this.onAddSet,
    required this.onDeleteSet,
    required this.onUpdateSet,
    required this.onEditNote,
    required this.showReordenar,
  }) : super(key: key);

  @override
  ExerciseCardState createState() => ExerciseCardState();
}

class ExerciseCardState extends State<ExerciseCard> {
  Map<int, int> selectedRegisterTypes = {};
  Map<int, TextEditingController> noteControllers = {};
  Map<int, bool> showNote = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    initControladores();
  }

  @override
  void didUpdateWidget(covariant ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Comprobar si los ejercicios detallados han cambiado.
    if (oldWidget.ejercicioDetalladoAgrupado !=
        widget.ejercicioDetalladoAgrupado) {
      initControladores();
    }
  }

  void initControladores() {
    widget.ejercicioDetalladoAgrupado.ejerciciosDetallados
        .asMap()
        .forEach((index, ejercicio) {
      selectedRegisterTypes[index] = 1;
      noteControllers[index] = TextEditingController(text: ejercicio.notes);
      if (ejercicio.notes != null && ejercicio.notes!.isNotEmpty) {
        showNote[index] = true;
      } else {
        showNote[index] = false;
      }
    });
  }

  @override
  void dispose() {
    noteControllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  void _handleMenuItemSelected(
      String value, int groupIndex, int exerciseIndex) {
    switch (value) {
      case 'reordenar':
        widget.showReordenar();
        setState(() {
          initControladores();
        });

        break;
      case 'nota':
        setState(() {
          showNote[exerciseIndex] = !showNote[exerciseIndex]!;
        });

        break;
      case 'eliminar':
        widget.onDeleteEjercicioDetalladoAgrupado(groupIndex, exerciseIndex);
        setState(() {
          initControladores();
        });
        break;
    }
  }

  void _onEditNote(int groupIndex, int exerciseIndex, String note) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onEditNote(groupIndex, exerciseIndex, note);
    });
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
    return Dismissible(
      key: Key(
        'group_${groupIndex}_exercise_${exerciseIndex}_${DateTime.now().millisecondsSinceEpoch}',
      ),
      onDismissed: (_) {
        widget.onDeleteEjercicioDetalladoAgrupado(groupIndex, exerciseIndex);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      child: Padding(
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
              trailing:
                  _buildPopupMenuButton(context, groupIndex, exerciseIndex),
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
                                  ejercicioDetallado.ejercicio!.muscleGroupId,
                                  [])
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
            //se muestra el textArea si hay texto o si se le ha dado a "nota"
            if ((noteControllers[exerciseIndex] != null &&
                    noteControllers[exerciseIndex]!.text.isNotEmpty) ||
                (showNote[exerciseIndex] == true)) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: noteControllers[exerciseIndex],
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (note) =>
                      _onEditNote(groupIndex, exerciseIndex, note),
                  decoration: const InputDecoration(
                    labelText: 'Instrucciones',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Set',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildRegisterTypeDropdown(exerciseIndex),
                  ),
                ],
              ),
            ),
            ...List.generate(ejercicioDetallado.setsEntrada?.length ?? 0, (i) {
              if (i < 0 || i >= ejercicioDetallado.setsEntrada!.length) {
                return const SizedBox.shrink();
              }
              int selectedRegisterType =
                  selectedRegisterTypes[exerciseIndex] ?? 1;
              return SetRow(
                set: ejercicioDetallado.setsEntrada![i],
                onDeleteSet: () =>
                    {widget.onDeleteSet(groupIndex, exerciseIndex, i)},
                selectedRegisterType: selectedRegisterType,
                onUpdateSet: (updatedSet) {
                  widget.onUpdateSet(groupIndex, exerciseIndex, i, updatedSet);
                },
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => widget.onAddSet(widget.index, exerciseIndex),
              child: const Text("+ añadir set"),
            ),
          ],
        ),
      ),
    );
  }

  _buildPopupMenuButton(
      BuildContext context, int groupIndex, int exerciseIndex) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'eliminar',
          child: Text('Eliminar'),
        ),
        const PopupMenuItem(
          value: 'reordenar',
          child: Text('Reordenar'),
        ),
        const PopupMenuItem(
          value: 'nota',
          child: Text('Escribir nota'),
        ),
      ],
      onSelected: (value) =>
          _handleMenuItemSelected(value, groupIndex, exerciseIndex),
    );
  }

  Widget _buildRegisterTypeDropdown(int ejercicioIndex) {
    // Asegúrate de inicializar el valor en initState o en el constructor si aún no se ha hecho.
    var selectedType = selectedRegisterTypes.containsKey(ejercicioIndex)
        ? selectedRegisterTypes[ejercicioIndex]
        : widget.registerTypes.first.registerTypeId;

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        isExpanded: true,
        menuMaxHeight: 300,
        value: selectedType,
        icon: const Icon(Icons.arrow_drop_down),
        onChanged: (newValue) {
          setState(() {
            selectedRegisterTypes[ejercicioIndex] = newValue!;
            widget.ejercicioDetalladoAgrupado
                .ejerciciosDetallados[ejercicioIndex].registerTypeId = newValue;
          });
        },
        items: widget.registerTypes.map((typeRegister) {
          return DropdownMenuItem<int>(
            value: typeRegister.registerTypeId,
            child: Text(typeRegister.name ?? "Sin nombre"),
          );
        }).toList(),
      ),
    );
  }
}

class SetRow extends StatefulWidget {
  final SetsEjerciciosEntrada set;
  final int selectedRegisterType;
  final Function(SetsEjerciciosEntrada) onUpdateSet;
  final Function() onDeleteSet;

  const SetRow({
    Key? key,
    required this.set,
    required this.selectedRegisterType,
    required this.onUpdateSet,
    required this.onDeleteSet,
  }) : super(key: key);

  @override
  SetRowState createState() => SetRowState();
}

class SetRowState extends State<SetRow> {
  late TextEditingController minController;
  late TextEditingController maxController;
  Timer? _debounce;

  @override
  void initState() {
    minController = TextEditingController();
    maxController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    _debounce?.cancel();
    super.dispose();
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
      SetsEjerciciosEntrada updatedSet = widget.set;
      int? intValue = int.tryParse(value);
      double? doubleValue = double.tryParse(value);

      switch (field) {
        case 'minReps':
          updatedSet.minReps = intValue;
          break;
        case 'maxReps':
          updatedSet.maxReps = intValue;
          break;
        case 'time':
          updatedSet.time = doubleValue;
          break;
        case 'minTime':
          updatedSet.minTime = doubleValue;
          break;
        case 'maxTime':
          updatedSet.maxTime = doubleValue;
          break;
        case 'reps':
          updatedSet.reps = intValue;
          break;
      }

      widget.onUpdateSet(updatedSet);
    });
  }

  List<Widget> _buildInputFields() {
    switch (widget.selectedRegisterType) {
      case 1: // Rango de repeticiones
        minController.text = widget.set.minReps?.toString() ?? '';
        maxController.text = widget.set.maxReps?.toString() ?? '';
        return [
          Expanded(
            child: IntInputField(
              controller: minController,
              onFieldSubmitted: (value) => _updateSet(value, 'minReps'),
            ),
          ),
          dash,
          Expanded(
            child: IntInputField(
              controller: maxController,
              onFieldSubmitted: (value) => _updateSet(value, 'maxReps'),
            ),
          ),
        ];
      case 4: // AMRAP
        return [
          const Expanded(child: Text('AMRAP', style: TextStyle(fontSize: 16))),
        ];
      case 5: // Tiempo
        minController.text = widget.set.time?.toString() ?? '';
        return [
          Expanded(
            child: DoubleInputField(
              controller: minController,
              onFieldSubmitted: (value) => _updateSet(value, 'time'),
            ),
          ),
          minText,
        ];
      case 6: // Rango de tiempo
        minController.text = widget.set.minTime?.toString() ?? '';
        maxController.text = widget.set.maxTime?.toString() ?? '';
        return [
          Expanded(
            child: DoubleInputField(
              controller: minController,
              onFieldSubmitted: (value) => _updateSet(value, 'minTime'),
            ),
          ),
          dash,
          Expanded(
            child: DoubleInputField(
              controller: maxController,
              onFieldSubmitted: (value) => _updateSet(value, 'maxTime'),
            ),
          ),
          minText,
        ];
      default: // Por defecto, solo repeticiones
        minController.text = widget.set.reps?.toString() ?? '';
        return [
          Expanded(
            child: IntInputField(
              controller: minController,
              onFieldSubmitted: (value) => _updateSet(value, 'reps'),
            ),
          ),
        ];
    }
  }

  Widget _buildSetRowItem() {
    List<Widget> inputFields = _buildInputFields();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text('${widget.set.setOrder}',
                style: const TextStyle(fontSize: 16))),
        Expanded(
          child: Row(children: inputFields),
        ),
        Expanded(
          child: IconButton(
            onPressed:
                widget.set.setOrder == 1 ? null : () => widget.onDeleteSet(),
            icon: Icon(
                widget.set.setOrder == 1 ? Icons.delete_outline : Icons.delete),
            color: widget.set.setOrder == 1 ? Colors.grey : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.set.setOrder == 1) {
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
          child: _buildSetRowItem(),
        ),
      );
    }
  }
}
