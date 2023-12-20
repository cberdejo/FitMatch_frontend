import 'package:fit_match/widget/post_card/start.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/post_card/review/review_input_widget.dart';
import 'package:fit_match/widget/post_card/review/review_list.dart';
import 'package:fit_match/services/review_service.dart';

class ReviewSummaryWidget extends StatefulWidget {
  final List<Review> reviews;
  final int userId;
  final int clientId;
  final int trainerId;

  const ReviewSummaryWidget(
      {Key? key,
      required this.reviews,
      required this.userId,
      required this.trainerId,
      required this.clientId})
      : super(key: key);

  @override
  _ReviewSummaryWidgetState createState() => _ReviewSummaryWidgetState();
}

class _ReviewSummaryWidgetState extends State<ReviewSummaryWidget> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final averageRating = calculateAverageRating(widget.reviews);
    final ratingCount = _calculateRatingCount();
    final maxCount = ratingCount.values
        .fold(0, (prev, element) => element > prev ? element : prev);
    final isReviewed =
        widget.reviews.any((review) => review.clientId == widget.clientId);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewHeader(),
          widget.reviews.isNotEmpty
              ? _buildHistogramAndStars(
                  ratingCount, maxCount, averageRating, width)
              : Container(),
          if (!isReviewed) _buildReviewButton(context, width),
          const SizedBox(height: 16),
          widget.reviews.isNotEmpty ? _buildReviewList() : Container(),
        ],
      ),
    );
  }

  Widget _buildReviewHeader() {
    if (widget.reviews.isEmpty) {
      return const Text(
        'No hay reseñas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      );
    } else {
      return const Text(
        'Resumen de reseñas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      );
    }
  }

  Widget _buildHistogramAndStars(Map<int, int> ratingCount, int maxCount,
      num averageRating, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHistogram(ratingCount, maxCount),
        _buildStarsAndRating(averageRating, width),
      ],
    );
  }

  Widget _buildHistogram(Map<int, int> ratingCount, int maxCount) {
    return Flexible(
      flex: 3,
      child: Column(
        children: ratingCount.entries.map((entry) {
          int flexValue = maxCount > 0 ? (entry.value * 75) ~/ maxCount : 0;
          return _buildHistogramBar(entry, flexValue);
        }).toList(),
      ),
    );
  }

  Widget _buildHistogramBar(MapEntry<int, int> entry, int flexValue) {
    return Row(
      children: [
        Text('${entry.key}'),
        const SizedBox(width: 8),
        Flexible(
          flex: flexValue,
          child: Container(height: 8, color: Colors.grey[300]),
        ),
        Flexible(
          flex: 25 - flexValue,
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildStarsAndRating(num averageRating, double width) {
    return Flexible(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          StarDisplay(
              value: averageRating, size: width > webScreenSize ? 32 : 16),
          Text(
            '(${widget.reviews.length} reseñas)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(BuildContext context, double width) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showReviewInput(context, width),
        icon: const Icon(Icons.edit, color: blueColor),
        label: const Text('Escribir una reseña',
            style: TextStyle(color: blueColor)),
      ),
    );
  }

  void _showReviewInput(BuildContext context, double width) {
    if (width < webScreenSize) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return _buildMobileReviewInput();
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return _buildWebReviewInput(context);
        },
      );
    }
  }

  Widget _buildMobileReviewInput() {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: ReviewInputWidget(
              onReviewSubmit: (double rating, String reviewText) async {
                await onReviewSubmit(
                    widget.userId, widget.trainerId, rating, reviewText);
              },
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildWebReviewInput(BuildContext context) {
    return AlertDialog(
      title: const Text('Escribe tu reseña'),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        child: ReviewInputWidget(
          onReviewSubmit: (double rating, String reviewText) async {
            await onReviewSubmit(
                widget.userId, widget.trainerId, rating, reviewText);
          },
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return widget.reviews.isNotEmpty
        ? ReviewListWidget(
            reviews: [widget.reviews.first],
            userId: widget.userId,
            clientId: widget.clientId,
            onReviewDeleted: (int reviewId) {
              setState(() {
                widget.reviews.removeWhere((item) => item.reviewId == reviewId);
                showToast(context, 'Reseña elimianda con éxito');
              });
            },
          )
        : Container();
  }

  Map<int, int> _calculateRatingCount() {
    Map<int, int> ratingCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in widget.reviews) {
      int roundedRating = review.rating.round();
      ratingCount[roundedRating] = (ratingCount[roundedRating] ?? 0) + 1;
    }
    return ratingCount;
  }

  Future<void> onReviewSubmit(
      num userId, num trainerId, double rating, String reviewText) async {
    try {
      if (reviewText.isEmpty) {
        showToast(context, 'El contenido no puede ser vacío');
      }
      Review review = await addReview(userId, trainerId, rating, reviewText);

      setState(() {
        widget.reviews.add(review);
        Navigator.pop(context);
        showToast(context, 'Reseña anadida con éxito');
      });
    } catch (e) {
      print('Error al añadir la review: $e');
    }
  }
}
