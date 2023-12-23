import 'package:fit_match/models/review.dart';

class Post {
  final int trainerId;
  final int userId;
  final String email;
  final String username;
  final String profilePicture;
  final String description;
  final String picture;
  final num price;
  List<Review> reviews;
  final DateTime birth;

  Post({
    required this.trainerId,
    required this.userId,
    required this.email,
    required this.username,
    required this.profilePicture,
    required this.description,
    required this.picture,
    required this.price,
    required this.reviews,
    required this.birth,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Review> reviews = (json['reviews'] as List?)
            ?.map((reviewJson) =>
                Review.fromJson(reviewJson as Map<String, dynamic>))
            .toList() ??
        [];

    return Post(
      trainerId: json['trainer_id'] as int,
      userId: json['user_id'] as int,
      email: json['email'] as String,
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
