class PlantillaPost {
  final int templateId;
  final int userId;
  final String templateName;
  final String? description;
  final String? picture;
  final bool public;
  final bool hidden;
  final List<Etiqueta> etiquetas;

  PlantillaPost({
    required this.templateId,
    required this.userId,
    required this.templateName,
    this.description,
    this.picture,
    required this.public,
    required this.hidden,
    required this.etiquetas,
  });

  factory PlantillaPost.fromJson(Map<String, dynamic> json) {
    return PlantillaPost(
      templateId: json['template_id'] as int,
      userId: json['user_id'] as int,
      templateName: json['template_name'] as String,
      description: json['description'] as String?,
      picture: json['picture'] as String?,
      public: json['public'] as bool,
      hidden: json['hidden'] as bool,
      etiquetas: (json['etiquetas'] as List)
          .map((etiquetaJson) => Etiqueta.fromJson(etiquetaJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'user_id': userId,
      'template_name': templateName,
      'description': description,
      'picture': picture,
      'public': public,
      'hidden': hidden,
      'etiquetas': etiquetas.map((etiqueta) => etiqueta.toJson()).toList(),
    };
  }

  // Método para obtener un mapeo de las secciones basado en etiquetas
  Map<String, dynamic> getSectionsMap() {
    Map<String, dynamic> sections = {
      'Experiencia': [],
      'Disciplinas': [],
      'Objetivos': [],
      'Equipamiento': [],
      'Duración': [],
    };

    for (var etiqueta in etiquetas) {
      if (etiqueta.experience != null && etiqueta.experience!.isNotEmpty) {
        sections['Experiencia'].add(etiqueta.experience);
      }
      if (etiqueta.interests != null && etiqueta.interests!.isNotEmpty) {
        sections['Disciplinas'].add(etiqueta.interests);
      }
      if (etiqueta.objectives != null && etiqueta.objectives!.isNotEmpty) {
        sections['Objetivos'].add(etiqueta.objectives);
      }
      if (etiqueta.equipment != null && etiqueta.equipment!.isNotEmpty) {
        sections['Equipamiento'].add(etiqueta.equipment);
      }
      if (etiqueta.duration != null && etiqueta.duration!.isNotEmpty) {
        sections['Duración'].add(etiqueta.duration);
      }
    }

    return sections;
  }
}

class Etiqueta {
  String? objectives;
  String? experience;
  String? interests;
  String? equipment;
  String? duration;

  Etiqueta(
      {this.objectives,
      this.experience,
      this.interests,
      this.equipment,
      this.duration});

  factory Etiqueta.fromJson(Map<String, dynamic> json) {
    return Etiqueta(
      objectives: json['objectives'],
      experience: json['experience'],
      interests: json['interests'],
      equipment: json['equipment'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectives': objectives,
      'experience': experience,
      'interests': interests,
      'equipment': equipment,
      'duration': duration,
    };
  }
}
