class RutinaGuardada {
  final int savedId;
  final int userId;
  final int templateId;

  RutinaGuardada({
    required this.savedId,
    required this.userId,
    required this.templateId,
  });

  factory RutinaGuardada.fromJson(Map<String, dynamic> json) {
    return RutinaGuardada(
      savedId: json['saved_id'],
      userId: json['user_id'],
      templateId: json['template_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saved_id': savedId,
      'user_id': userId,
      'template_id': templateId,
    };
  }
}
