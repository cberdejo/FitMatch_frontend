import 'package:fit_match/models/review.dart';

class Post {
  final num userId;
  final num trainerId;
  final String email;
  final String username;
  final String profilePicture;
  final String description;
  final String picture;
  final num price;
  final List<Review> reviews;
  final DateTime birth;

  Post({
    required this.trainerId,
    required this.email,
    required this.userId,
    required this.username,
    required this.profilePicture,
    required this.description,
    required this.picture,
    required this.reviews,
    required this.price,
    required this.birth,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var rawReviews = json['reviews'] as List<dynamic>? ?? [];
    var reviews =
        rawReviews.map((reviewJson) => Review.fromJson(reviewJson)).toList();

    return Post(
      email: json['email'] as String,
      userId: json['user_id'] as num,
      trainerId: json['trainer_id'] as num,
      username: json['username'] as String,
      profilePicture: json['profile_picture'] as String,
      description: json['description'] as String,
      picture: json['picture'] as String,
      price: json['price'] as num,
      birth: DateTime.parse(json['birth'] as String),
      reviews: reviews,
    );
  }
}
