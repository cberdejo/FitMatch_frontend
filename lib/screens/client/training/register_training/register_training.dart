import 'package:fit_match/models/ejercicios.dart';
import 'package:fit_match/models/registros.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/registro_service.dart';
import 'package:fit_match/widget/custom_button.dart';
import 'package:fit_match/widget/exercise_card/register_card.dart';
import 'package:fit_match/widget/expandable_text.dart';
import 'package:flutter/material.dart';

class RegisterTrainingScreen extends StatefulWidget {
  final User user;
  final int sessionId;

  const RegisterTrainingScreen({
    super.key,
    required this.sessionId,
    required this.user,
  });
  @override
  _RegisterTrainingScreen createState() => _RegisterTrainingScreen();
}

class _RegisterTrainingScreen extends State<RegisterTrainingScreen> {
  SesionEntrenamiento existingSession = SesionEntrenamiento(
    sessionId: 0,
    templateId: 0,
    sessionName: 'Nueva sesión de entrenamiento',
    order: 0,
    sessionDate: DateTime.now(),
  );

  void _saveEntrenamiento() async {
    int activeSessionId = existingSession.registros!
        .firstWhere((element) => !element.finished)
        .registerSessionId;

    bool exito = await RegistroMethods().terminarRegistro(activeSessionId);

    if (exito) {
      _navigateBack(context, reload: true);
    }
  }

  List<EjerciciosDetalladosAgrupados> _exercises = [];

  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
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

  Widget _buildSectionContent(String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: ExpandableText(text: content),
    );
  }

  bool _existeRegistroActivo(SesionEntrenamiento session) {
    if (session.registros == null || session.registros!.isEmpty) {
      return false;
    }

    return session.registros!.any((element) => !element.finished);
  }

  Future<void> _initData() async {
    setState(() => isLoading = true); // Empieza a cargar
    SesionEntrenamiento session;
    try {
      session = await RegistroMethods().getSessionEntrenamientoWithRegistros(
          widget.user.user_id as int,
          widget
              .sessionId); //Obtengo la sesión de entrenamiento con sus registros
    } catch (e) {
      print("Error en getSessionEntrenamientoWithRegistros: $e");
      setState(() => isLoading = false);
      return;
    }

    try {
      if (!_existeRegistroActivo(session)) {
        //en caso de que no exista ningún registro activo creo uno
        var newRegistro = await RegistroMethods().createRegisterSession(
            widget.user.user_id as int, session.sessionId);
        session.registros ??= [];
        session.registros!.add(newRegistro); //se añade al final
      }
    } catch (e) {
      print("Error en createRegisterSession: $e");
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      existingSession = session;
      _exercises = session.ejerciciosDetalladosAgrupados!;
    });

    await Future.wait(
        session.ejerciciosDetalladosAgrupados!.map((ejercicioAgrupado) async {
      for (var setEntrada in ejercicioAgrupado.ejerciciosDetallados) {
        await Future.wait(setEntrada.setsEntrada!
            .map((set) => _onAddSet(set, initial: true)));
      }
    }));

    setState(() {
      isLoading = false;
    });
  }

  void _navigateBack(BuildContext context, {bool reload = false}) {
    Navigator.pop(context, reload);
  }

  Future<void> _onAddSet(SetsEjerciciosEntrada set, {initial = false}) async {
    try {
      // Obtener la sesión activa.
      RegistroDeSesion activeRegistroSession = _getActiveSession();

      // Verificar si el set ya existe para la sesión activa.
      if (!initial ||
          !_registerSetAlreadyExists(
              set, activeRegistroSession.registerSessionId)) {
        // Crear y añadir el nuevo registro de set.
        RegistroSet newRegistroSet = await _createAndAddRegistroSet(
            set, activeRegistroSession.registerSessionId);

        // Actualizar el estado con el nuevo set.
        _updateSetState(set, newRegistroSet);
      }
    } catch (e) {
      print("Error en _onAddSet: $e");
    }
  }

  RegistroDeSesion _getActiveSession() {
    return existingSession.registros!
        .firstWhere((element) => !element.finished);
  }

  /// Comprueba si el Registroset ya existe en la sesión.
  bool _registerSetAlreadyExists(
      SetsEjerciciosEntrada set, num registerSessionId) {
    return set.registroSet?.any((registroSet) =>
            registroSet.registerSessionId == registerSessionId) ??
        false;
  }

  /// Crea y añade un nuevo registro de set.
  Future<RegistroSet> _createAndAddRegistroSet(
      SetsEjerciciosEntrada set, num registerSessionId) async {
    return await RegistroMethods().addOrUpdateRegisterSet(
        userId: widget.user.user_id as int,
        setId: set.setId!,
        registerSessionId: registerSessionId as int,
        create: true);
  }

  /// Actualiza el estado con el nuevo set.
  void _updateSetState(SetsEjerciciosEntrada set, RegistroSet registroSet) {
    setState(() {
      set.registroSet ??= [];
      set.registroSet!.add(registroSet);
    });
  }

  void _onDeleteSet(SetsEjerciciosEntrada set, RegistroSet registroSet) async {
    bool exito =
        await RegistroMethods().eliminarRegistroSet(registroSet.registerSetId);
    if (exito) {
      setState(() {
        set.registroSet!.remove(registroSet);
      });
    }
  }

  void _updateSet(SetsEjerciciosEntrada set, index_registro) async {
    if (set.registroSet == null) {
      return;
    }

    RegistroSet existingRegistroSet =
        set.registroSet!.elementAt(index_registro);

    int activeSessionId = existingSession.registros!
        .firstWhere((element) => !element.finished)
        .registerSessionId;

    RegistroSet updatedSet = await RegistroMethods().addOrUpdateRegisterSet(
        userId: widget.user.user_id as int,
        setId: set.setId!,
        registerSessionId: activeSessionId,
        registerSetId: existingRegistroSet.registerSetId,
        reps: existingRegistroSet.reps,
        weight: existingRegistroSet.weight,
        time: existingRegistroSet.time);

    setState(() {
      int index = set.registroSet!.indexWhere(
          (rs) => rs.registerSetId == existingRegistroSet.registerSetId);
      if (index != -1) {
        set.registroSet![index] = updatedSet;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
          appBar: AppBar(
            title: Text(existingSession.sessionName),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _navigateBack(context, reload: true),
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
                                const SizedBox(height: 16),
                                _buildInstructionsField(context),
                                const SizedBox(height: 16),
                                _buildEntrenamientosList(context),
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
            return RegisterCard(
              ejercicioDetalladoAgrupado: _exercises[index],
              index: index,
              registerSessionId:
                  existingSession.registros!.first.registerSessionId,
              system: widget.user.system,
              onAddSet: (set) => _onAddSet(set),
              onDeleteSet: (set, registro) => _onDeleteSet(set, registro),
              onUpdateSet: (set, index_registro) =>
                  _updateSet(set, index_registro),
            );
          });
    }
  }

  Widget _buildInstructionsField(BuildContext context) {
    return _buildSectionContent(existingSession.notes ?? '');
  }

  Widget _buildSaveButton(BuildContext context) {
    return CustomButton(onTap: _saveEntrenamiento, text: 'Terminar');
  }
}
