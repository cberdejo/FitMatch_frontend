import 'dart:async';
import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/exercise/create_exercise_screen.dart';
import 'package:fit_match/services/sesion_entrenamientos_service.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/utils.dart';

import 'package:fit_match/widget/exercise_list_item_seletable.dart';
import 'package:fit_match/widget/search_widget.dart';
import 'package:flutter/material.dart';

class ManageExerciseScreen extends StatefulWidget {
  final User user;
  const ManageExerciseScreen({
    super.key,
    required this.user,
  });
  @override
  ManageExerciseScreenState createState() => ManageExerciseScreenState();
}

class ManageExerciseScreenState extends State<ManageExerciseScreen> {
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

  _deleteExercise(int exerciseId, {multiple = false}) async {
    try {
      bool deleted = await EjerciciosMethods().deleteExercise(exerciseId);
      if (deleted && !multiple) {
        showToast(context, 'El ejercicio ha sido eliminado', exitoso: true);
      }
      if (!multiple) {
        _resetAndLoadExercises();
      }
    } catch (e) {
      print(e);
    }
  }

  _editExercise(Ejercicios exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateExerciseScreen(user: widget.user, exercise: exercise),
      ),
    ).then((value) => _resetAndLoadExercises());
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
            cursor: selectedExercisesOrder.isNotEmpty
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: GestureDetector(
              onTap: selectedExercisesOrder.isNotEmpty
                  ? () async {
                      // Ejecuta la eliminación de ejercicios seleccionados aquí
                      for (var entry in selectedExercisesOrder.entries) {
                        await _deleteExercise(entry.key, multiple: true);
                      }
                      //En caso de eliminar varios, haremos el reset al final y mostraremos el toast al final
                      showToast(context, 'Se han eliminado los ejercicios');
                      _resetAndLoadExercises();

                      setState(() {
                        selectedExercisesOrder.clear();
                      });
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: selectedExercisesOrder.isNotEmpty
                          ? Colors.red
                          : Colors.grey),
                  color: selectedExercisesOrder.isNotEmpty
                      ? Colors.white
                      : Colors.grey[300],
                ),
                child: Text(
                  'Borrar ejercicios${selectedExercisesOrder.isNotEmpty ? ' (${selectedExercisesOrder.length})' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedExercisesOrder.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateExerciseScreen(
                  user: widget.user,
                ),
              )),
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
                    onDeletedExercise: () =>
                        _deleteExercise(exercises[index].exerciseId),
                    onEditExercise: () => _editExercise(exercises[index]),
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
          menuMaxHeight: 300,
          value: selectedEquipmentId,
          icon: const Icon(Icons.arrow_drop_down),
          onChanged: (newValue) {
            setState(() {
              selectedEquipmentId = newValue;
            });
            exercises.clear();
            _currentPage = 1; // Restablece la paginación
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
