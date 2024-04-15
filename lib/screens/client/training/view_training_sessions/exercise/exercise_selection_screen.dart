import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/exercise/create_exercise_screen.dart';
import 'package:fit_match/services/sesion_entrenamientos_service.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';

import 'package:fit_match/widget/exercise_list_item_seletable.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/material.dart';

class ExecriseSelectionScreen extends StatefulWidget {
  final User user;
  final int sessionId;
  final int groupedDetailedExerciseOrder;
  const ExecriseSelectionScreen(
      {super.key,
      required this.user,
      required this.sessionId,
      required this.groupedDetailedExerciseOrder});
  @override
  ExecriseSelectionState createState() => ExecriseSelectionState();
}

class ExecriseSelectionState extends State<ExecriseSelectionScreen> {
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  List<Ejercicios> exercises = [];
  Map<int, int> selectedExercisesOrder = {};

  List<GrupoMuscular> muscleGroups = [];
  int? selectedMuscleGroupId;

  List<Equipment> equipment = [];
  int? selectedEquipmentId;

  String filtroBusqueda = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreExercisesOnScroll);
    _loadExercises();
    _initMuscleGroups();
    _initEquipment();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_loadMoreExercisesOnScroll);
    _debounce?.cancel();
  }

  void _loadMoreExercisesOnScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadExercises();
      }
    }
  }

  void _resetAndLoadExercises() {
    setState(() {
      exercises.clear(); // Limpia la lista de ejercicios
      _currentPage = 1; // Restablece la paginación a la primera página
      _hasMore = true; // Asegura que la paginación pueda continuar
    });
    _loadExercises(); // Carga los ejercicios con los filtros actualizados
  }

  void _loadExercises() async {
    // Si no hay más posts o ya está cargando, retorna.
    if (!_hasMore || _isLoading) return;

    // Inicia la carga de posts.
    _setLoadingState(true);

    try {
      // Obtener ejercicios.
      List<Ejercicios> exercises = await EjerciciosMethods().getAllEjercicios(
        userId: widget.user.user_id,
        page: _currentPage,
        pageSize: _pageSize,
        name: filtroBusqueda.isNotEmpty
            ? filtroBusqueda
            : null, // Añadido filtro por nombre
        idGrupoMuscular: selectedMuscleGroupId,
        idMaterial: selectedEquipmentId,
      );
      if (exercises.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      }
      // Actualizar la lista de posts y el estado si el componente sigue montado.
      else if (mounted) {
        _updateExerciseList(exercises);
      }
    } catch (e) {
      print(e);
    } finally {
      // Finalmente, asegura que se actualice el estado de carga.
      if (mounted) {
        _setLoadingState(false);
      }
    }
  }

  void _updateExerciseList(List<Ejercicios> newExecises) {
    setState(() {
      _currentPage++;
      exercises.addAll(newExecises);
    });
  }

  void _initMuscleGroups() async {
    List<GrupoMuscular> groups =
        await EjerciciosMethods().getGruposMusculares();
    setState(() {
      muscleGroups = groups;
    });
  }

  void _initEquipment() async {
    List<Equipment> mats = await EjerciciosMethods().getMaterial();
    setState(() {
      equipment = mats;
    });
  }

  void _selectExercise(Ejercicios ejercicio) {
    setState(() {
      if (selectedExercisesOrder.containsKey(ejercicio.exerciseId)) {
        selectedExercisesOrder.remove(ejercicio.exerciseId);
      } else {
        selectedExercisesOrder[ejercicio.exerciseId] =
            selectedExercisesOrder.length + 1;
      }
    });
  }

  _editExercise(Ejercicios exercis) async {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CreateExerciseScreen(
              user: widget.user,
              exercise: exercis,
            ),
          ),
        )
        .then((value) => _resetAndLoadExercises());
  }

  _deleteExercise(Ejercicios exercise) async {
    try {
      bool deleted =
          await EjerciciosMethods().deleteExercise(exercise.exerciseId);
      if (deleted) {
        showToast(context, 'El ejercicio ha sido eliminado', exitoso: true);
      }
      _resetAndLoadExercises();
    } catch (e) {
      print(e);
    }
  }

  void _prepareAndNavigateBack(bool modoSuperSet) {
    List<EjerciciosDetalladosAgrupados> exercisesGroups = [];

    if (modoSuperSet) {
      // Añadir como super set
      List<EjercicioDetallado> ejerciciosDetallados =
          selectedExercisesOrder.entries.map((entry) {
        Ejercicios? ejercicios =
            exercises.firstWhereOrNull((e) => e.exerciseId == entry.key);
        return EjercicioDetallado(
            exerciseId: entry.key,
            order: entry.value,
            registerTypeId: 1,
            notes: '',
            setsEntrada: [SetsEjerciciosEntrada(setOrder: 1)],
            ejercicio: ejercicios);
      }).toList();

      exercisesGroups.add(EjerciciosDetalladosAgrupados(
        sessionId: widget.sessionId,
        order: widget.groupedDetailedExerciseOrder,
        ejerciciosDetallados: ejerciciosDetallados,
      ));
    } else {
      // Añadir individualmente
      int currentOrder = widget.groupedDetailedExerciseOrder;
      for (var entry in selectedExercisesOrder.entries) {
        Ejercicios? ejercicios =
            exercises.firstWhereOrNull((e) => e.exerciseId == entry.key);
        exercisesGroups.add(EjerciciosDetalladosAgrupados(
          sessionId: widget.sessionId,
          order: currentOrder++,
          ejerciciosDetallados: [
            EjercicioDetallado(
              exerciseId: entry.key,
              order: entry.value,
              registerTypeId: 1,
              notes: '', // Notas por defecto
              setsEntrada: [SetsEjerciciosEntrada(setOrder: 1)],
              ejercicio: ejercicios,
            ),
          ],
        ));
      }
    }
    _navigateBack(exercisesGroups);
  }

  void _navigateBack(List<EjerciciosDetalladosAgrupados>? exercises) {
    Navigator.pop(context, exercises);
  }

  void _setLoadingState(bool loading) {
    setState(() => _isLoading = loading);
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        filtroBusqueda = text;
      });

      // Iniciar una nueva búsqueda con el nuevo filtro
      exercises
          .clear(); // Limpia la lista actual antes de cargar nuevos resultados
      _currentPage = 1; // Restablece a la primera página
      _hasMore = true;

      _loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SearchWidget(
              text: filtroBusqueda,
              hintText: 'Buscar ejercicios',
              onChanged: (text) => _onSearchChanged(text),
            )),
        actions: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (context) => CreateExerciseScreen(
                        user: widget.user,
                      ),
                    ),
                  )
                  .then((value) => _resetAndLoadExercises()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Crear ejercicio',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimary),
                  textScaler: width < webScreenSize
                      ? const TextScaler.linear(1)
                      : const TextScaler.linear(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildMuscleGroupDropdown(),
                const SizedBox(height: 10),
                _buildMaterialDropdown(),
              ],
            ),
          ),
          //ejercicios lista
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  exercises.length + 1, // +1 para el posible indicador de carga
              itemBuilder: (context, index) {
                if (index < exercises.length) {
                  final isSelected = selectedExercisesOrder
                      .containsKey(exercises[index].exerciseId);
                  return BuildExerciseItem(
                    profiledId: widget.user.profile_id,
                    userId: widget.user.user_id,
                    ejercicio: exercises[index],
                    isSelected: isSelected,
                    order: selectedExercisesOrder[exercises[index].exerciseId],
                    onEditExercise: () => _editExercise(exercises[index]),
                    onDeletedExercise: () => _deleteExercise(exercises[index]),
                    onSelectedEjercicio: (exercise) =>
                        _selectExercise(exercise),
                    onPressedInfo: () async {
                      String? iconName = await getIconNameByMuscleGroupId(
                          exercises[index].muscleGroupId, muscleGroups);

                      showDialogExerciseInfo(
                          context,
                          exercises[index].name,
                          exercises[index].description,
                          iconName,
                          exercises[index].video);
                    },
                  );
                } else {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Container();
                }
              },
            ),
          ),
          selectedExercisesOrder.isNotEmpty
              ? _buildPersistentFooterButtons(MediaQuery.of(context).size.width)
              : Container(),
        ],
      ),
    );
  }

  Widget _buildPersistentFooterButtons(num width) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _prepareAndNavigateBack(false);
              },
              child: Text(
                'Añadir individualmente',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
                textScaler: width < webScreenSize
                    ? const TextScaler.linear(1)
                    : const TextScaler.linear(1.2),
              ),
            ),
          ),
          selectedExercisesOrder.length > 1
              ? Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _prepareAndNavigateBack(true);
                    },
                    child: Text(
                      'Añadir como super set',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      textScaler: width < webScreenSize
                          ? const TextScaler.linear(1)
                          : const TextScaler.linear(1.2),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Selecciona un grupo muscular",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          menuMaxHeight: 300,
          value: selectedMuscleGroupId,
          icon: const Icon(
            Icons.arrow_drop_down,
          ),
          onChanged: (newValue) {
            setState(() {
              selectedMuscleGroupId = newValue;
            });
            exercises
                .clear(); // Limpia los ejercicios actuales para cargar los nuevos filtrados
            _currentPage = 1; // Restablece la paginación
            _hasMore = true;
            _loadExercises(); // Carga los ejercicios con los nuevos filtros
          },
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                "Todos",
              ),
            ),
            ...muscleGroups.map((group) {
              return DropdownMenuItem<int>(
                value: group.muscleGroupId,
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context)
                          .size
                          .width), // Restringe el ancho máximo
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Usa el espacio mínimo necesario para los hijos
                    children: [
                      Flexible(
                        // Usa Flexible en lugar de Expanded para permitir que el texto se ajuste
                        child: Text(
                          group.name ?? "Sin nombre",
                          overflow: TextOverflow
                              .ellipsis, // Asegúrate de que el texto no se desborde
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (group.iconName != null &&
                          group.iconName!.isNotEmpty &&
                          group.muscleGroupId != selectedMuscleGroupId)
                        Image.asset(
                          "assets/images/muscle_groups/${group.iconName}.png",
                          width: 24,
                          height: 24,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDropdown() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: "Selecciona un material",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          //dropdownColor: Theme.of(context).colorScheme.primaryContainer,
          menuMaxHeight: 300,
          value: selectedEquipmentId,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (newValue) {
            setState(() {
              selectedEquipmentId = newValue;
            });
            exercises
                .clear(); // Limpia los ejercicios actuales para cargar los nuevos filtrados
            _currentPage = 1; // Restablece la paginación
            _hasMore = true;

            _resetAndLoadExercises();
          },
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text("Todos"),
            ),
            ...equipment.map((mat) {
              return DropdownMenuItem<int>(
                value: mat.materialId,
                child: Text(mat.name),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
