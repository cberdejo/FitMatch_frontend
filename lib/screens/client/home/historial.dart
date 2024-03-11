import 'package:fit_match/models/user.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewHistorialScreen extends StatefulWidget {
  final User user;
  const ViewHistorialScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ViewHistorialScreen createState() => _ViewHistorialScreen();
}

class _ViewHistorialScreen extends State<ViewHistorialScreen> {
  DateTime?
      selectedDay; // Cambiado para permitir nulo, indicando ninguna selección
  DateTime focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay;
      this.focusedDay = focusedDay;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedDay = null; // Limpia la selección
      focusedDay = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        buildCalendarTable(),
        if (selectedDay !=
            null) // Muestra la fecha solo si hay una seleccionada
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "Viendo sesiones de entrenamientos realizadas en ${selectedDay!.day}/${selectedDay!.month}/${selectedDay!.year}"),
          ),
        if (selectedDay != null)
          ElevatedButton(
            onPressed: _clearSelection,
            child: const Text('Limpiar selección'),
          ),
      ])),
    );
  }

  Widget buildCalendarTable() {
    return TableCalendar(
      locale: "es_Es",
      focusedDay: focusedDay,
      availableGestures: AvailableGestures.all,
      selectedDayPredicate: (selectedDay) => isSameDay(selectedDay, focusedDay),
      onDaySelected: _onDaySelected,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.now().add(const Duration(days: 365)),
    );
  }
}
