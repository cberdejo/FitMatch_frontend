import 'package:fit_match/models/user.dart';

class RegistroDeSesion {
  final int registerSessionId;
  final int userId;
  final int sessionId;
  final DateTime date;
  final DateTime? final_date;
  bool finished;
  final User? usuario;
  List<RegistroSet>? registroSet;

  RegistroDeSesion({
    required this.registerSessionId,
    required this.userId,
    required this.sessionId,
    required this.date,
    required this.finished,
    this.final_date,
    this.usuario,
    this.registroSet,
  });

  factory RegistroDeSesion.fromJson(Map<String, dynamic> json) {
    return RegistroDeSesion(
      registerSessionId: json['register_session_id'],
      userId: json['user_id'],
      sessionId: json['session_id'],
      date: DateTime.parse(json['date']),
      final_date: json['final_date'] != null
          ? DateTime.parse(json['final_date'])
          : null,
      finished: json['finished'],
      usuario: json['user'] != null ? User.fromJson(json['user']) : null,
      registroSet: json['registro_set'] != null
          ? (json['registro_set'] as List)
              .map((e) => RegistroSet.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'register_session_id': registerSessionId,
      'user_id': userId,
      'session_id': sessionId,
      'date': date.toIso8601String(),
      'final_date': final_date?.toIso8601String(),
      'finished': finished,
    };

    if (registroSet != null) {
      data['registro_set'] = registroSet!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}

class RegistroSet {
  final int registerSetId;
  final int? registerSessionId;
  final int setId;
  int? reps;
  num? weight;
  num? time;
  DateTime timestamp;
  String? video;
  // final RegistroDeSesion registroDeSesion;
  // final SetsEjerciciosEntrada setsEjerciciosEntrada;

  RegistroSet({
    required this.registerSetId,
    this.registerSessionId,
    required this.setId,
    this.reps,
    this.weight,
    this.time,
    required this.timestamp,
    this.video,
  });

  factory RegistroSet.fromJson(Map<String, dynamic> json) {
    return RegistroSet(
      registerSetId: json['register_set_id'],
      registerSessionId: json['register_session_id'],
      setId: json['set_id'],
      reps: json['reps'],
      weight: json['weight'],
      time: json['time'],
      timestamp: DateTime.parse(json['timestamp']),
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'register_set_id': registerSetId,
      'register_session_id': registerSessionId,
      'set_id': setId,
      'reps': reps,
      'weight': weight,
      'time': time,
      'timestamp': timestamp.toIso8601String(),
      'video': video,
    };
  }
}
