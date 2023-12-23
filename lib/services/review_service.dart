import 'dart:convert';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/utils/backendUrls.dart';
import 'package:http/http.dart' as http;

Future<MeGusta> likeReview(num userId, num reviewId) async {
  final response = await http.post(
    Uri.parse(likeReviewUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'userId': userId, 'reviewId': reviewId}),
  );

  if (response.statusCode == 200) {
    return MeGusta.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al dar Like Código de estado: ${response.statusCode}');
  }
}

Future<Review> addReview(
    num clientId, num trainerId, num rating, String reviewContent) async {
  final response = await http.post(
    Uri.parse(reviewsUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': clientId,
      'trainerId': trainerId,
      'rating': rating,
      'reviewContent': reviewContent
    }),
  );

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    return Review.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al crear la review. Código de estado: ${response.statusCode}');
  }
}

Future<void> deleteReview(num reviewId) async {
  await http.delete(
    Uri.parse('$reviewsUrl/$reviewId'),
    headers: {
      'Content-Type': 'application/json',
    },
  );
}

Future<ComentarioReview> answerReview(
    num userId, num reviewId, String answer) async {
  final response = await http.post(
    Uri.parse(commentReviewUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body:
        jsonEncode({'userId': userId, 'reviewId': reviewId, 'answer': answer}),
  );

  if (response.statusCode == 200) {
    return ComentarioReview.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al añadir comentarios. Código de estado: ${response.statusCode}');
  }
}

Future<ComentarioReview> answerComment(
    num commentId, num userId, num reviewId, String answer) async {
  final response = await http.post(
    Uri.parse(commentReviewCommentUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'reviewId': reviewId,
      'answer': answer,
      'commentId': commentId
    }),
  );

  if (response.statusCode == 200) {
    return ComentarioReview.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al responder comentario. Código de estado: ${response.statusCode}');
  }
}

Future<void> deleteComment(num commentId) async {
  await http.delete(
    Uri.parse('$commentUrl/$commentId'),
    headers: {
      'Content-Type': 'application/json',
    },
  );
}
