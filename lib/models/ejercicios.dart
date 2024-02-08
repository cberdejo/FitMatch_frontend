class EjerciciosDetalladosAgrupados {
  final int groupedDetailedExercisedId;
  final int sessionId;
  final int order;
  final List<EjercicioDetallado> ejerciciosDetallados;

  EjerciciosDetalladosAgrupados({
    required this.groupedDetailedExercisedId,
    required this.sessionId,
    required this.order,
    required this.ejerciciosDetallados,
  });

  factory EjerciciosDetalladosAgrupados.fromJson(Map<String, dynamic> json) {
    return EjerciciosDetalladosAgrupados(
      groupedDetailedExercisedId: json['grouped_detailed_exercised_id'],
      sessionId: json['session_id'],
      order: json['order'],
      ejerciciosDetallados: (json['ejercicios_detallados'] as List<dynamic>)
          .map((e) => EjercicioDetallado.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grouped_detailed_exercised_id': groupedDetailedExercisedId,
      'session_id': sessionId,
      'order': order,
      'ejercicios_detallados':
          ejerciciosDetallados.map((e) => e.toJson()).toList(),
    };
  }
}

class EjercicioDetallado {
  final int detailedExerciseId;
  final int? exerciseId;
  final int registerTypeId;
  final String? notes;
  final int order;
  final Ejercicios? ejercicios;

  EjercicioDetallado({
    required this.detailedExerciseId,
    this.exerciseId,
    required this.registerTypeId,
    this.notes,
    required this.order,
    this.ejercicios,
  });

  factory EjercicioDetallado.fromJson(Map<String, dynamic> json) {
    return EjercicioDetallado(
      detailedExerciseId: json['detailed_exercise_id'],
      exerciseId: json['exercise_id'],
      registerTypeId: json['register_type_id'],
      notes: json['notes'],
      order: json['order'],
      ejercicios: json['ejercicios'] != null
          ? Ejercicios.fromJson(json['ejercicios'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'detailed_exercise_id': detailedExerciseId,
      'exercise_id': exerciseId,
      'register_type_id': registerTypeId,
      'notes': notes,
      'order': order,
      'ejercicios': ejercicios?.toJson(),
    };
  }
}

class Ejercicios {
  final int exerciseId;
  final String name;
  final String? description;
  final int muscleGroupId;
  final int? materialId;

  Ejercicios({
    required this.exerciseId,
    required this.name,
    this.description,
    required this.muscleGroupId,
    this.materialId,
  });

  factory Ejercicios.fromJson(Map<String, dynamic> json) {
    return Ejercicios(
      exerciseId: json['exercise_id'],
      name: json['name'],
      description: json['description'],
      muscleGroupId: json['muscle_group_id'],
      materialId: json['material_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'name': name,
      'description': description,
      'muscle_group_id': muscleGroupId,
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
  final int muscleGroupId;
  final String? name;
  //final List<Ejercicios> ejercicios;

  GrupoMuscular({
    required this.muscleGroupId,
    this.name,
    //required this.ejercicios,
  });

  factory GrupoMuscular.fromJson(Map<String, dynamic> json) {
    return GrupoMuscular(
      muscleGroupId: json['muscle_group_id'],
      name: json['name'],
      /* 
     ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => Ejercicios.fromJson(ejercicio))
          .toList(),
      */
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'muscle_group_id': muscleGroupId,
      'name': name,
      //'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}

class Equipment {
  final int materialId;
  final String name;
  //final List<Ejercicios> ejercicios;

  Equipment({
    required this.materialId,
    required this.name,
    //required this.ejercicios,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      materialId: json['material_id'],
      name: json['name'],
      /*ejercicios: (json['ejercicios'] as List)
          .map((ejercicio) => Ejercicios.fromJson(ejercicio))
          .toList(),
          */
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'name': name,
      //'ejercicios': ejercicios.map((ejercicio) => ejercicio.toJson()).toList(),
    };
  }
}
