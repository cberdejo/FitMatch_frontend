class Ejercicio {
  final int exerciseId;
  final String name;
  final String? description;

  Ejercicio({
    required this.exerciseId,
    required this.name,
    this.description,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      exerciseId: json['exercise_id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'description': description,
    };
  }
}

class EjercicioConDetalles {
  final int detailedExerciseId;
  final int exerciseId;
  final int sessionId;
  final String? notes;
  final String? video;
  final int? intensity;
  final int? targetSets;
  final int? targetReps;
  final DateTime? targetTime;
  final bool? armrap;

  EjercicioConDetalles({
    required this.detailedExerciseId,
    required this.exerciseId,
    required this.sessionId,
    this.notes,
    this.video,
    this.intensity,
    this.targetSets,
    this.targetReps,
    this.targetTime,
    this.armrap,
  });

  factory EjercicioConDetalles.fromJson(Map<String, dynamic> json) {
    return EjercicioConDetalles(
      detailedExerciseId: json['detailed_exercise_id'] as int,
      exerciseId: json['exercise_id'] as int,
      sessionId: json['session_id'] as int,
      notes: json['notes'] as String?,
      video: json['video'] as String?,
      intensity: json['intensity'] as int?,
      targetSets: json['target_sets'] as int?,
      targetReps: json['target_reps'] as int?,
      targetTime: json.containsKey('target_time') && json['target_time'] != null
          ? DateTime.parse(json['target_time'])
          : null,
      armrap: json['armrap'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailed_exercise_id': detailedExerciseId,
      'exercise_id': exerciseId,
      'session_id': sessionId,
      'notes': notes,
      'video': video,
      'intensity': intensity,
      'target_sets': targetSets,
      'target_reps': targetReps,
      'target_time': targetTime?.toIso8601String(),
      'armrap': armrap,
    };
  }
}

class EjercicioEntrada {
  final int entryExerciseId;
  final int entrySessionId;
  final int detailedExerciseId;
  final String? notes;
  final List<SetEjercicioEntrada> sets;

  EjercicioEntrada({
    required this.entryExerciseId,
    required this.entrySessionId,
    required this.detailedExerciseId,
    this.notes,
    required this.sets,
  });

  factory EjercicioEntrada.fromJson(Map<String, dynamic> json) {
    return EjercicioEntrada(
      entryExerciseId: json['entry_exercise_id'] as int,
      entrySessionId: json['entry_session_id'] as int,
      detailedExerciseId: json['detailed_exercise_id'] as int,
      notes: json['notes'] as String?,
      sets: (json['sets'] as List<dynamic>)
          .map((setJson) => SetEjercicioEntrada.fromJson(setJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_exercise_id': entryExerciseId,
      'entry_session_id': entrySessionId,
      'detailed_exercise_id': detailedExerciseId,
      'notes': notes,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}

class SetEjercicioEntrada {
  final int setId;
  final int entryExerciseId;
  final int? setOrder;
  final String? video;
  final int? reps;
  final double? weight;
  final DateTime? time;

  SetEjercicioEntrada({
    required this.setId,
    required this.entryExerciseId,
    this.setOrder,
    this.video,
    this.reps,
    this.weight,
    this.time,
  });

  factory SetEjercicioEntrada.fromJson(Map<String, dynamic> json) {
    return SetEjercicioEntrada(
      setId: json['set_id'] as int,
      entryExerciseId: json['entry_exercise_id'] as int,
      setOrder: json['set_order'] as int?,
      video: json['video'] as String?,
      reps: json['reps'] as int?,
      weight: json['weight'] as double,
      time: json.containsKey('time') && json['time'] != null
          ? DateTime.parse(json['time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'entry_exercise_id': entryExerciseId,
      'set_order': setOrder,
      'video': video,
      'reps': reps,
      'weight': weight,
      'time': time?.toIso8601String(),
    };
  }
}
