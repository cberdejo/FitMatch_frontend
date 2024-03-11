import 'package:fit_match/models/registros.dart';

class EjerciciosDetalladosAgrupados {
  final int? groupedDetailedExercisedId; //se omite si es para creación
  final int sessionId;
  int order;
  final List<EjercicioDetallado> ejerciciosDetallados;

  EjerciciosDetalladosAgrupados({
    this.groupedDetailedExercisedId,
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
  final int? detailedExerciseId; //se omite si es para creación
  final int? exerciseId;
  int registerTypeId;
  String? notes;
  int order;
  final Ejercicios? ejercicio;
  List<SetsEjerciciosEntrada>? setsEntrada;

  EjercicioDetallado(
      {this.detailedExerciseId,
      this.exerciseId,
      required this.registerTypeId,
      this.notes,
      required this.order,
      this.ejercicio,
      this.setsEntrada});

  factory EjercicioDetallado.fromJson(Map<String, dynamic> json) {
    return EjercicioDetallado(
      detailedExerciseId: json['detailed_exercise_id'],
      exerciseId: json['exercise_id'],
      registerTypeId: json['register_type_id'],
      notes: json['notes'],
      order: json['order'],
      ejercicio: json['ejercicios'] != null
          ? Ejercicios.fromJson(json['ejercicios'])
          : null,
      setsEntrada: json['sets_ejercicios_entrada'] != null
          ? (json['sets_ejercicios_entrada'] as List)
              .map((e) => SetsEjerciciosEntrada.fromJson(e))
              .toList()
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
      'ejercicios': ejercicio?.toJson(),
      'sets_ejercicios_entrada': setsEntrada?.map((e) => e.toJson()).toList(),
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
  final int? setId; //null para crear
  final int? detailedExerciseId;
  List<RegistroSet>? registroSet;
  int setOrder;
  int? reps;
  double? time;
  int? minReps;
  int? maxReps;
  double? minTime;
  double? maxTime;

  SetsEjerciciosEntrada({
    this.setId,
    this.detailedExerciseId,
    this.registroSet,
    required this.setOrder,
    this.reps,
    this.time,
    this.minReps,
    this.maxReps,
    this.minTime,
    this.maxTime,
  });

  factory SetsEjerciciosEntrada.fromJson(Map<String, dynamic> json) {
    return SetsEjerciciosEntrada(
      setId: json['set_id'],
      detailedExerciseId: json['detailed_exercise_id'],
      setOrder: json['set_order'],
      reps: json['reps'],
      time: json['time'],
      minReps: json['min_reps'],
      maxReps: json['max_reps'],
      minTime: json['min_time'],
      maxTime: json['max_time'],
      registroSet: json['registro_set'] != null && json['registro_set'] != []
          ? (json['registro_set'] as List)
              .map((e) => RegistroSet.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_id': setId,
      'detailed_exercise_id': detailedExerciseId,
      'set_order': setOrder,
      'reps': reps,
      'time': time,
      'min_reps': minReps,
      'max_reps': maxReps,
      'min_time': minTime,
      'max_time': maxTime,
      'registro_set': registroSet?.map((e) => e.toJson()).toList(),
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
