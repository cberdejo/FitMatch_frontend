import 'package:fit_match/models/ejercicios.dart';

class SesionEntrenamiento {
  final int sessionId;
  final int templateId;
  final DateTime session_date;
  final String notes;
  final List<EjercicioConDetalles> ejercicios;

  SesionEntrenamiento({
    required this.sessionId,
    required this.templateId,
    required this.session_date,
    required this.notes,
    required this.ejercicios,
  });

  factory SesionEntrenamiento.fromJson(Map<String, dynamic> json) {
    return SesionEntrenamiento(
      sessionId: json['session_id'],
      templateId: json['template_id'],
      session_date: DateTime.parse(json['session_date']),
      notes: json['notes'],
      ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => EjercicioConDetalles.fromJson(ejercicio))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'template_id': templateId,
      'session_date': session_date.toIso8601String(),
      'notes': notes,
      'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}
