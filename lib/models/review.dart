class Review {
  final int reviewId;
  final int userId;
  final int templateId;
  final num rating;
  final String reviewContent;
  final DateTime timestamp;
  final String username;
  final List<ComentarioReview> comentarioReview;
  final List<MeGustaReviews> meGusta;

  Review({
    required this.reviewId,
    required this.userId,
    required this.templateId,
    required this.rating,
    required this.reviewContent,
    required this.timestamp,
    required this.username,
    this.comentarioReview = const [],
    this.meGusta = const [],
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as int,
      userId: json['user_id'] as int,
      templateId: json['template_id'] as int,
      rating: json['rating'] as num,
      reviewContent: json['review_content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      username: json['username'] as String,
      comentarioReview: (json['comentario_review'] as List?)
              ?.map(
                  (comentarioJson) => ComentarioReview.fromJson(comentarioJson))
              .toList() ??
          [],
      meGusta: (json['me_gusta_reviews'] as List?)
              ?.map((meGustaJson) => MeGustaReviews.fromJson(meGustaJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'user_id': userId,
      'template_id': templateId,
      'rating': rating,
      'review_content': reviewContent,
      'timestamp': timestamp.toIso8601String(),
      'username': username,
      'comentario_review':
          comentarioReview.map((comentario) => comentario.toJson()).toList(),
      'me_gusta_reviews': meGusta.map((mg) => mg.toJson()).toList(),
    };
  }
}

//COMENTARIO
class ComentarioReview {
  final int commentId;
  final int reviewId;
  final num userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final List<MeGustaComentarios> meGusta;

  ComentarioReview({
    required this.commentId,
    required this.reviewId,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.username,
    this.meGusta = const [],
  });

  factory ComentarioReview.fromJson(Map<String, dynamic> json) {
    return ComentarioReview(
        commentId: json['comment_id'] as int,
        reviewId: json['review_id'] as int,
        userId: json['user_id'] as num,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        username: json['username'] as String,
        meGusta: (json['me_gusta_comentarios'] as List?)
                ?.map((meGustaJson) => MeGustaComentarios.fromJson(meGustaJson))
                .toList() ??
            []);
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'review_id': reviewId,
      'user_id': userId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'username': username,
      'me_gusta_comentarios': meGusta.map((mg) => mg.toJson()).toList(),
    };
  }
}

//ME GUSTA

class MeGustaReviews {
  final int likedReviewId;
  final int reviewId;
  final int userId;

  MeGustaReviews({
    required this.likedReviewId,
    required this.reviewId,
    required this.userId,
  });

  factory MeGustaReviews.fromJson(Map<String, dynamic> json) {
    return MeGustaReviews(
      likedReviewId: json['liked_review_id'] as int,
      reviewId: json['review_id'] as int,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked_review_id': likedReviewId,
      'review_id': reviewId,
      'user_id': userId,
    };
  }
}

class MeGustaComentarios {
  final int likedCommentId;
  final int commentId;
  final int userId;

  MeGustaComentarios({
    required this.likedCommentId,
    required this.commentId,
    required this.userId,
  });

  factory MeGustaComentarios.fromJson(Map<String, dynamic> json) {
    return MeGustaComentarios(
      likedCommentId: json['liked_comment_id'] as int,
      commentId: json['comment_id'] as int,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liked_comment_id': likedCommentId,
      'comment_id': commentId,
      'user_id': userId,
    };
  }
}
