import 'package:fit_match/models/review.dart';

class PlantillaPost {
  final int templateId;
  final int userId;
  final String templateName;
  final String? description;
  final String? picture;
  final bool public;
  final List<Review> reviews;
  final List<Etiqueta> etiquetas;

  PlantillaPost({
    required this.templateId,
    required this.userId,
    required this.templateName,
    this.description,
    this.picture,
    required this.public,
    required this.reviews,
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
      reviews: (json['reviews'] as List)
          .map((reviewJson) => Review.fromJson(reviewJson))
          .toList(),
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
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'etiquetas': etiquetas.map((etiqueta) => etiqueta.toJson()).toList(),
    };
  }
}

class Etiqueta {
  String? objectives;
  String? experience;
  String? interests;
  String? equipment;

  Etiqueta({this.objectives, this.experience, this.interests, this.equipment});

  factory Etiqueta.fromJson(Map<String, dynamic> json) {
    return Etiqueta(
      objectives: json['objetivos'],
      experience: json['experiencia'],
      interests: json['intereses'],
      equipment: json['equipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectives': objectives,
      'experience': experience,
      'interests': interests,
      'equipment': equipment,
    };
  }
}
