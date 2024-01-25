class EjercicioDetallados {
  final int detailedExerciseId;
  final int sessionId;
  final int exerciseId;
  final int registerTypeId;
  final String notes;
  final int order;
  final List<SetsEjerciciosEntrada> setsEjerciciosEntrada;

  EjercicioDetallados({
    required this.detailedExerciseId,
    required this.sessionId,
    required this.exerciseId,
    required this.registerTypeId,
    required this.notes,
    required this.order,
    required this.setsEjerciciosEntrada,
  });

  factory EjercicioDetallados.fromJson(Map<String, dynamic> json) {
    return EjercicioDetallados(
      detailedExerciseId: json['detailed_exercise_id'],
      sessionId: json['session_id'],
      exerciseId: json['exercise_id'],
      registerTypeId: json['register_type_id'],
      notes: json['notes'],
      order: json['order'],
      setsEjerciciosEntrada: (json['sets_ejercicios_entrada'] as List)
          .map((set) => SetsEjerciciosEntrada.fromJson(set))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailed_exercise_id': detailedExerciseId,
      'session_id': sessionId,
      'exercise_id': exerciseId,
      'register_type_id': registerTypeId,
      'notes': notes,
      'order': order,
      'sets_ejercicios_entrada':
          setsEjerciciosEntrada.map((set) => set.toJson()).toList(),
    };
  }
}

class Ejercicios {
  final int exerciseId;
  final String name;
  final String? description;
  final int muscularGroupId;
  final int? materialId;

  Ejercicios({
    required this.exerciseId,
    required this.name,
    this.description,
    required this.muscularGroupId,
    this.materialId,
  });

  factory Ejercicios.fromJson(Map<String, dynamic> json) {
    return Ejercicios(
      exerciseId: json['exercise_id'],
      name: json['name'],
      description: json['description'],
      muscularGroupId: json['muscular_group_id'],
      materialId: json['material_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'description': description,
      'muscular_group_id': muscularGroupId,
      'material_id': materialId,
    };
  }
}

class SetsEjerciciosEntrada {
  final int setId;
  final int? detailedExerciseId;
  final int? setOrder;
  final int? reps;
  final DateTime? time;
  final double? weight;
  final String? video;

  SetsEjerciciosEntrada({
    required this.setId,
    this.detailedExerciseId,
    this.setOrder,
    this.reps,
    this.time,
    this.weight,
    this.video,
  });

  factory SetsEjerciciosEntrada.fromJson(Map<String, dynamic> json) {
    return SetsEjerciciosEntrada(
      setId: json['set_id'],
      detailedExerciseId: json['detailed_exercise_id'],
      setOrder: json['set_order'],
      reps: json['reps'],
      time: DateTime.tryParse(json['time']),
      weight: json['weight'],
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'detailed_exercise_id': detailedExerciseId,
      'set_order': setOrder,
      'reps': reps,
      'time': time?.toIso8601String(),
      'weight': weight,
      'video': video,
    };
  }
}

class TipoDeRegistro {
  final int registerTypeId;
  final String? name;

  TipoDeRegistro({
    required this.registerTypeId,
    this.name,
  });

  factory TipoDeRegistro.fromJson(Map<String, dynamic> json) {
    return TipoDeRegistro(
      registerTypeId: json['register_type_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'register_type_id': registerTypeId,
      'name': name,
    };
  }
}

class GrupoMuscular {
  final int muscularGroupId;
  final String? name;
  final List<Ejercicios> ejercicios;

  GrupoMuscular({
    required this.muscularGroupId,
    this.name,
    required this.ejercicios,
  });

  factory GrupoMuscular.fromJson(Map<String, dynamic> json) {
    return GrupoMuscular(
      muscularGroupId: json['muscular_group_id'],
      name: json['name'],
      ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => Ejercicios.fromJson(ejercicio))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muscular_group_id': muscularGroupId,
      'name': name,
      'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}
