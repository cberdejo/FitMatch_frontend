import 'package:fit_match/models/ejercicios.dart';

class SesionEntrenamiento {
  final int sessionId;
  final int templateId;
  final String sessionName;
  final DateTime sessionDate;
  final String notes;
  final List<EjercicioDetallados> ejercicios;

  SesionEntrenamiento({
    required this.sessionId,
    required this.templateId,
    required this.sessionDate,
    required this.sessionName,
    required this.notes,
    required this.ejercicios,
  });

  factory SesionEntrenamiento.fromJson(Map<String, dynamic> json) {
    return SesionEntrenamiento(
      sessionId: json['session_id'],
      templateId: json['template_id'],
      sessionDate: DateTime.parse(json['session_date']),
      sessionName: json['session_name'],
      notes: json['notes'],
      ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => EjercicioDetallados.fromJson(ejercicio))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'template_id': templateId,
      'session_date': sessionDate.toIso8601String(),
      'session_name': sessionName,
      'notes': notes,
      'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}
