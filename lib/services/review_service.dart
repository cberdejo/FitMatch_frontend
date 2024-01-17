import 'dart:convert';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/utils/backend_urls.dart';
import 'package:http/http.dart' as http;

Future<MeGustaReviews> likeReview(num userId, num reviewId) async {
  final response = await http.post(
    Uri.parse(likeReviewUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'userId': userId, 'reviewId': reviewId}),
  );

  if (response.statusCode == 200) {
    return MeGustaReviews.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al dar Like Código de estado: ${response.statusCode}');
  }
}

Future<MeGustaComentarios> likeComment(num userId, num commentId) async {
  final response = await http.post(
    Uri.parse(likeCommentUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'userId': userId, 'commentId': commentId}),
  );

  if (response.statusCode == 200) {
    return MeGustaComentarios.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al dar Like Código de estado: ${response.statusCode}');
  }
}

Future<Review> addReview(
    num userId, num templateId, num rating, String reviewContent) async {
  final response = await http.post(
    Uri.parse(reviewsUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'userId': userId,
      'templateId': templateId,
      'rating': rating,
      'reviewContent': reviewContent
    }),
  );

  if (response.statusCode == 200) {
    return Review.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(
        'Error al crear la reseña. Código de estado: ${response.statusCode}');
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

Future<List<Review>> getAllReviews(num templateId,
    {int? page = 1, int? pageSize = 10, String? reviewOrder}) async {
  String url = "$reviewsUrl?templateId=$templateId";

  if (page != null) {
    url += "&page=$page";
  }

  if (pageSize != null) {
    url += "&pageSize=$pageSize";
  }

  if (reviewOrder != null) {
    url += "&reviewOrder=$reviewOrder";
  }

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body) as List;
    return jsonData.map((jsonItem) => Review.fromJson(jsonItem)).toList();
  } else {
    throw Exception(
        'Error al obtener los posts. Código de estado: ${response.statusCode}');
  }
}
