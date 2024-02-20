import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/view_training_sessions/exercise/exercise_selection_screen.dart';
import 'package:fit_match/services/sesion_entrenamientos_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:fit_match/widget/exercise_card/exercise_card.dart';
import 'package:fit_match/widget/exercise_card/reorder_exercise_card.dart';
import 'package:flutter/material.dart';

class InfoSesionEntrenamientoScreen extends StatefulWidget {
  final int templateId;
  final User user;
  final int sessionId;

  const InfoSesionEntrenamientoScreen({
    super.key,
    required this.sessionId,
    required this.templateId,
    required this.user,
  });
  @override
  _InfoSesionEntrenamientoScreen createState() =>
      _InfoSesionEntrenamientoScreen();
}

class _InfoSesionEntrenamientoScreen
    extends State<InfoSesionEntrenamientoScreen> {
  SesionEntrenamiento editingSesion = SesionEntrenamiento(
    sessionId: 0,
    templateId: 0,
    sessionName: '',
    order: 0,
    sessionDate: DateTime.now(),
  );

  List<EjerciciosDetalladosAgrupados> _exercises = [];
  List<TipoDeRegistro> _registerTypes = [];

  bool isLoading = true;
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _instruccionesController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tituloController.dispose();
    _instruccionesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _setLoadingState(bool loading) {
    setState(() => isLoading = loading);
  }

  void _initRegisterType() async {
    List<TipoDeRegistro> groups =
        await EjerciciosMethods().getTiposDeRegistro();
    setState(() {
      _registerTypes = groups;
    });
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    try {
      var session = await SesionEntrenamientoMethods()
          .getSesionesEntrenamientoBySessionId(widget.sessionId);
      var registerTypes = await EjerciciosMethods().getTiposDeRegistro();
      setState(() {
        editingSesion = session;
        _registerTypes = registerTypes;
        _tituloController.text = session.sessionName;
        _instruccionesController.text = session.notes ?? '';
        isLoading = false;
      });
      _initExercises();
    } catch (e) {
      setState(() => isLoading = false);
      print(e); // Consider using a more user-friendly error handling
    }
  }

  Future<void> _showReordenar() async {
    final List<EjerciciosDetalladosAgrupados>? result =
        await Navigator.of(context).push<List<EjerciciosDetalladosAgrupados>>(
      MaterialPageRoute(
        builder: (context) =>
            ReorderExercises(ejerciciosDetalladosAgrupados: _exercises),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _exercises = result;
      });
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estás seguro?'),
        content: const Text('Perderás todo el progreso.'),
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
      _navigateBack(context);
    }

    return Future.value(
        false); // Evita que el botón de retroceso cierre la pantalla automáticamente.
  }

  Future<void> _initExercises() async {
    try {
      var exercises = await EjercicioDetalladosAgrupadoMethods()
          .getEjerciciosDetalladosAgrupadosBySesionId(widget.sessionId);
      setState(() => _exercises = exercises);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _addExercise() async {
    final List<EjerciciosDetalladosAgrupados>? result =
        await Navigator.of(context).push<List<EjerciciosDetalladosAgrupados>>(
      MaterialPageRoute(
        builder: (context) => ExecriseSelectionScreen(
          user: widget.user,
          sessionId: widget.sessionId,
          GroupedDetailedExerciseOrder: _exercises.length,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _exercises.addAll(result);
      });
    }
  }

  Future<void> _saveEntrenamiento() async {
    if (_formKey.currentState!.validate()) {
      try {
        SesionEntrenamiento sesion = SesionEntrenamiento(
          sessionId: editingSesion.sessionId,
          templateId: editingSesion.templateId,
          sessionName: _tituloController.text,
          notes: _instruccionesController.text,
          sessionDate: editingSesion.sessionDate,
          order: editingSesion.order,
          ejerciciosDetalladosAgrupados: _exercises,
        );

        int response =
            await SesionEntrenamientoMethods().editSesionEntrenamiento(sesion);

        if (response == 200) {
          showToast(
              context, 'Sesión de Entrenamiento actualizada correctamente');
          _navigateBack(context, reload: true);
        }
      } catch (e) {
        showToast(context, e.toString(), exitoso: false);
      }
    }
  }

  void _navigateBack(BuildContext context, {bool reload = false}) {
    Navigator.pop(context, reload);
  }

  void _onAddSet(int groupIndex, int exerciseIndex) {
    List<SetsEjerciciosEntrada> setsEjerciciosEntrada = _exercises[groupIndex]
            .ejerciciosDetallados[exerciseIndex]
            .setsEntrada ??
        [];

    int setOrder = setsEjerciciosEntrada.isNotEmpty
        ? setsEjerciciosEntrada.last.setOrder + 1
        : 1;

    setsEjerciciosEntrada.add(SetsEjerciciosEntrada(setOrder: setOrder));

    setState(() {
      _exercises[groupIndex].ejerciciosDetallados[exerciseIndex].setsEntrada =
          setsEjerciciosEntrada;
    });
  }

  void _onDeleteSet(int groupIndex, int exerciseIndex, int setIndex) {
    setState(() {
      List<SetsEjerciciosEntrada>? setsEjerciciosEntrada =
          _exercises[groupIndex]
              .ejerciciosDetallados[exerciseIndex]
              .setsEntrada;

      if (setsEjerciciosEntrada != null &&
          setsEjerciciosEntrada.isNotEmpty &&
          setIndex < setsEjerciciosEntrada.length) {
        setsEjerciciosEntrada.removeAt(setIndex);

        // Corregir el orden de los sets restantes
        for (int i = 0; i < setsEjerciciosEntrada.length; i++) {
          setsEjerciciosEntrada[i].setOrder = i + 1;
        }
      }
    });
  }

  void _updateSet(int groupIndex, int exerciseIndex, int setIndex,
      SetsEjerciciosEntrada set) {
    setState(() {
      List<SetsEjerciciosEntrada>? setsEjerciciosEntrada =
          _exercises[groupIndex]
              .ejerciciosDetallados[exerciseIndex]
              .setsEntrada;
      setsEjerciciosEntrada?[setIndex] = set;
    });
  }

  void _onEditNote(int groupIndex, int exerciseIndex, String note) {
    setState(() {
      _exercises[groupIndex].ejerciciosDetallados[exerciseIndex].notes = note;
    });
  }

  void _onDeleteEjercicioDetalladoAgrupado(int groupIndex, int exerciseIndex) {
    int? deleteId =
        _exercises[groupIndex].ejerciciosDetallados[exerciseIndex].exerciseId;
    if (deleteId != null) {
      setState(() {
        // Eliminar el ejercicio detallado del grupo
        _exercises[groupIndex].ejerciciosDetallados.removeAt(exerciseIndex);

        // Corregir el orden de los ejercicios
        for (int i = 0;
            i < _exercises[groupIndex].ejerciciosDetallados.length;
            i++) {
          _exercises[groupIndex].ejerciciosDetallados[i].order = i + 1;
        }
        // Eliminar el grupo si no hay ejercicios
        if (_exercises[groupIndex].ejerciciosDetallados.isEmpty) {
          _exercises.removeAt(groupIndex);
          // Corregir el orden de los grupos
          for (int i = 0; i < _exercises.length; i++) {
            _exercises[i].order = i + 1;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Sesión de Entrenamiento'),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                await _onWillPop();
              },
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Container(
                    alignment: Alignment.topCenter,
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTitleField(context),
                                const SizedBox(height: 16),
                                _buildInstructionsField(context),
                                const SizedBox(height: 16),
                                _buildEntrenamientosList(context),
                                const SizedBox(height: 16),
                                _buildNewExerciseButton(context),
                                const SizedBox(height: 16),
                                _buildSaveButton(context),
                              ]),
                        )),
                  ),
                )),
    );
  }

  Widget _buildEntrenamientosList(BuildContext context) {
    if (_exercises.isEmpty) {
      return const Text(
        'No hay ejercicios todavía',
        style: TextStyle(fontSize: 18),
      );
    } else {
      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            return ExerciseCard(
              ejercicioDetalladoAgrupado: _exercises[index],
              registerTypes: _registerTypes,
              index: index,
              onDeleteEjercicioDetalladoAgrupado: (groupIndex, exerciseIndex) =>
                  _onDeleteEjercicioDetalladoAgrupado(
                      groupIndex, exerciseIndex),
              onAddSet: (groupIndex, exerciseIndex) =>
                  _onAddSet(groupIndex, exerciseIndex),
              onDeleteSet: (groupIndex, exerciseIndex, setIndex) =>
                  _onDeleteSet(groupIndex, exerciseIndex, setIndex),
              onUpdateSet: (groupIndex, exerciseIndex, setIndex, set) =>
                  _updateSet(groupIndex, exerciseIndex, setIndex, set),
              onEditNote: (groupIndex, exerciseIndex, note) =>
                  _onEditNote(groupIndex, exerciseIndex, note),
              showReordenar: () => _showReordenar(),
            );
          });
    }
  }

  Widget _buildTitleField(BuildContext context) {
    return TextFormField(
      controller: _tituloController,
      decoration: const InputDecoration(
        labelText: 'Nombre de la sesión de entrenamiento',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, escribe el nombre de tu sesión de entrenamiento';
        }
        return null;
      },
    );
  }

  Widget _buildInstructionsField(BuildContext context) {
    return TextFormField(
      controller: _instruccionesController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        labelText: 'Instrucciones de la sesión de entrenamiento',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNewExerciseButton(BuildContext context) {
    return CustomButton(onTap: _addExercise, text: 'Añadir Ejercicio');
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(
        onTap: _saveEntrenamiento, text: 'Guardar sesión de entrenamiento');
  }
}
