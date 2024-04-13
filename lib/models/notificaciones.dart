class Notificacion {
  int? notificationId;
  int userId;
  String type;
  String mensaje;
  bool read;
  DateTime timestamp;

  Notificacion({
    this.notificationId,
    required this.userId,
    required this.type,
    required this.mensaje,
    this.read = false,
    required this.timestamp,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      type: json['type'],
      mensaje: json['mensaje'],
      read: json['read'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'type': type,
      'mensaje': mensaje,
      'read': read,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
