import 'package:fit_match/models/ejercicios.dart';

class SesionEntrenamientoEntrada {
  final int entrySessionId;
  final int userId;
  final int sessionId;
  final DateTime sessionDate;
  final List<EjercicioEntrada> ejercicios;

  SesionEntrenamientoEntrada({
    required this.entrySessionId,
    required this.userId,
    required this.sessionId,
    required this.sessionDate,
    required this.ejercicios,
  });

  factory SesionEntrenamientoEntrada.fromJson(Map<String, dynamic> json) {
    return SesionEntrenamientoEntrada(
      entrySessionId: json['entry_session_id'],
      userId: json['user_id'],
      sessionId: json['session_id'],
      sessionDate: DateTime.parse(json['session_date']),
      ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => EjercicioEntrada.fromJson(ejercicio))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_session_id': entrySessionId,
      'user_id': userId,
      'session_id': sessionId,
      'session_date': sessionDate.toIso8601String(),
      'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}
