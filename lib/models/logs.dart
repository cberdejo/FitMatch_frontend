abstract class Registro {}

class Log extends Registro {
  final int id;
  final DateTime fecha;
  final bool exito;
  final String ipAddress;
  final String email;

  Log({
    required this.id,
    required this.fecha,
    required this.exito,
    required this.ipAddress,
    required this.email,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'],
      fecha: DateTime.parse(json['fecha']),
      exito: json['exito'], // Asumiendo que el valor viene como entero
      ipAddress: json['ip_address'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'exito': exito ? 1 : 0, // Convierte bool a entero para JSON
      'ip_address': ipAddress,
      'email': email,
    };
  }
}

class Bloqueo extends Registro {
  final int id;
  final String ipAddress;
  final DateTime timestamp;
  final DateTime fechaHasta;

  Bloqueo({
    required this.id,
    required this.timestamp,
    required this.ipAddress,
    required this.fechaHasta,
  });

  factory Bloqueo.fromJson(Map<String, dynamic> json) {
    return Bloqueo(
      id: json['id'],
      ipAddress: json['ip_address'],
      timestamp: DateTime.parse(json['timestamp']),
      fechaHasta: DateTime.parse(json['fecha_hasta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'ip_address': ipAddress,
      'fecha_hasta': fechaHasta.toIso8601String(),
    };
  }
}
