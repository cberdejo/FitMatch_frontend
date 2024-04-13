class Medidas {
  int? measurementId; //null para crear
  final int userId;
  final double? leftArm;
  final double? rightArm;
  final double? leftForearm;
  final double? rightForearm;
  final double? shoulders;
  final double? neck;
  final double? chest;
  final double? waist;
  final double? upperLeftLeg;
  final double? upperRightLeg;
  final double? leftCalve;
  final double? rightCalve;
  final double? weight;
  final List<FotosProgreso>? fotosProgreso;
  final DateTime? timestamp; //null para crear

  Medidas({
    this.timestamp,
    required this.userId,
    this.measurementId,
    this.leftArm,
    this.rightArm,
    this.leftForearm,
    this.rightForearm,
    this.shoulders,
    this.neck,
    this.chest,
    this.waist,
    this.upperLeftLeg,
    this.upperRightLeg,
    this.leftCalve,
    this.rightCalve,
    this.weight,
    this.fotosProgreso,
  });

  factory Medidas.fromJson(Map<String, dynamic> json) {
    return Medidas(
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      measurementId: json['measurement_id'],
      userId: json['user_id'],
      leftArm: json['left_arm']?.toDouble(),
      rightArm: json['right_arm']?.toDouble(),
      leftForearm: json['left_forearm']?.toDouble(),
      rightForearm: json['right_forearm']?.toDouble(),
      shoulders: json['shoulders']?.toDouble(),
      neck: json['neck']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      upperLeftLeg: json['upper_left_leg']?.toDouble(),
      upperRightLeg: json['upper_right_leg']?.toDouble(),
      leftCalve: json['left_calve']?.toDouble(),
      rightCalve: json['right_calve']?.toDouble(),
      weight: json['weight']?.toDouble(),
      fotosProgreso: json['fotos_progreso'] != null
          ? (json['fotos_progreso'] as List)
              .map((e) => FotosProgreso.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurement_id': measurementId,
      'user_id': userId,
      'left_arm': leftArm,
      'right_arm': rightArm,
      'shoulders': shoulders,
      'neck': neck,
      'chest': chest,
      'waist': waist,
      'upper_left_leg': upperLeftLeg,
      'upper_right_leg': upperRightLeg,
      'left_calve': leftCalve,
      'right_calve': rightCalve,
      'weight': weight,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class FotosProgreso {
  final int id;
  final int measurementId;
  final String imagen;

  FotosProgreso({
    required this.id,
    required this.measurementId,
    required this.imagen,
  });

  factory FotosProgreso.fromJson(Map<String, dynamic> json) {
    return FotosProgreso(
      id: json['id'],
      measurementId: json['measurement_id'],
      imagen: json['imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'measurement_id': measurementId,
      'imagen': imagen,
    };
  }
}

class StatMedida {
  final double value;
  final DateTime date;
  StatMedida({required this.value, required this.date});
}
