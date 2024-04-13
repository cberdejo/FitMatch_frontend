import 'package:fit_match/models/registros.dart';
import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/services/registro_service.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/exercise_card/registo_historial_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewHistorialScreen extends StatefulWidget {
  final User user;
  const ViewHistorialScreen({Key? key, required this.user}) : super(key: key);

  @override
  ViewHistorialState createState() => ViewHistorialState();
}

class ViewHistorialState extends State<ViewHistorialScreen> {
  List<SesionEntrenamiento> sesiones = [];
  DateTime?
      selectedDay; // Cambiado para permitir nulo, indicando ninguna selección
  DateTime focusedDay = DateTime.now();
  bool isLoading = true;
  List<DateTime> fechasDeSesiones = [];

  @override
  void initState() {
    super.initState();
    _initSesiones();
  }

  void _initSesiones() async {
    List<SesionEntrenamiento> sesiones = await RegistroMethods()
        .getSesionesWithRegisterByUserId(widget.user.user_id as int);

    var fechasDeSesiones = <DateTime>{};

    for (var sesion in sesiones) {
      for (var registro in sesion.registros ?? []) {
        if (registro.final_date != null) {
          fechasDeSesiones.add(registro.final_date!);
        }
      }
    }
    setState(() {
      this.sesiones = sesiones;
      this.fechasDeSesiones = fechasDeSesiones.toList();
      isLoading = false;
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      isLoading = true;
    });
    List<SesionEntrenamiento> sesiones = await RegistroMethods()
        .getSesionesWithRegisterByUserId(widget.user.user_id as int,
            fecha: selectedDay);

    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
      this.sesiones = sesiones;

      isLoading = false;
    });
  }

  void _clearSelection() async {
    setState(() {
      isLoading = true;
    });
    List<SesionEntrenamiento> sesiones = await RegistroMethods()
        .getSesionesWithRegisterByUserId(widget.user.user_id as int);
    setState(() {
      selectedDay = null; // Limpia la selección
      focusedDay = DateTime.now();
      this.sesiones = sesiones;
      isLoading = false;
    });
  }

  _deleteRegistro(RegistroDeSesion registro) async {
    bool exito = await RegistroMethods()
        .eliminarRegistroSession(registro.registerSessionId);
    if (exito) {
      showToast(context, 'Registro eliminado', exitoso: true);
    }

    _initSesiones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildCalendarTable(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    constraints: const BoxConstraints(maxWidth: 1500),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: selectedDay != null
                                ? Text(
                                    DateFormat.yMMMMd('es_ES')
                                        .format(selectedDay!),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  )
                                : Text(
                                    "Historial (${sesiones.length})",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                          ),
                        ),
                        if (selectedDay != null)
                          ElevatedButton(
                            onPressed: _clearSelection,
                            child: const Text('Limpiar selección'),
                          ),
                      ],
                    ),
                  ),
            const Divider(),
            sesiones.isEmpty && !isLoading
                ? const Text('No hay registros todavía')
                : Container(),
            Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: _createRegistroHistorialCards(sesiones),
                ))
          ],
        ),
      ),
    );
  }

  List<Widget> _createRegistroHistorialCards(
      List<SesionEntrenamiento> sesiones) {
    List<Widget> cards = [];
    for (var sesion in sesiones) {
      if (sesion.registros != null && sesion.registros!.isNotEmpty) {
        for (var registro in sesion.registros!) {
          cards.add(RegistroHistorialCard(
            session: sesion,
            registro: registro,
            user: widget.user,
            onDelete: (registro) => _deleteRegistro(registro),
          ));
        }
      }
    }
    return cards;
  }

  Widget buildCalendarTable() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: TableCalendar(
          locale: "es_Es",
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.month,
          availableGestures: AvailableGestures.all,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
          ),
          enabledDayPredicate: (day) {
            // Habilitar solo los días que tienen sesiones
            return fechasDeSesiones
                .any((fechaDeSesion) => isSameDay(fechaDeSesion, day));
          },
          calendarBuilders: CalendarBuilders(
            // Personaliza cómo se muestran los días que tienen sesiones
            defaultBuilder: (context, day, focusedDay) {
              bool isSessionDay = fechasDeSesiones
                  .any((fechaDeSesion) => isSameDay(fechaDeSesion, day));
              bool isToday = isSameDay(day, DateTime.now());
              double containerHeight = isToday ? 60 : 40;
              // Destacar el día si tiene una sesión programada
              if (isSessionDay) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  height: containerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      // Mostrar "Hoy" si el día es el día actual
                      if (isToday)
                        Text(
                          'Hoy',
                          style: TextStyle(
                            fontSize:
                                10, // Tamaño de fuente más pequeño para "Hoy"
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                );
              } else {
                // Para días sin sesiones, puedes retornar null o personalizar según necesites
                return null; // Retorna null para usar el builder por defecto
              }
            },

            // Personaliza el día actual
            todayBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSameDay(day, focusedDay)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      day.day.toString(),
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.orange
                            : Colors.yellow,
                      ),
                    ),
                    Text(
                      'Hoy',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.orange
                            : Colors.yellow,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          selectedDayPredicate: (selectedDay) =>
              isSameDay(selectedDay, focusedDay),
          onDaySelected: _onDaySelected,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.now().add(const Duration(days: 365)),
        ),
      ),
    );
  }
}
