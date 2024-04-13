import 'package:fit_match/models/user.dart';
import 'package:fit_match/widget/post_card/star.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/widget/post_card/review/review_input_widget.dart';
import 'package:fit_match/widget/post_card/review/review_list.dart';
import 'package:fit_match/services/review_service.dart';

class ReviewSummaryWidget extends StatefulWidget {
  final List<Review> reviews;
  final Function onReviewAdded;
  final User user;
  final int templateId;

  const ReviewSummaryWidget({
    Key? key,
    required this.reviews,
    required this.user,
    required this.templateId,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  ReviewSummaryWidgetState createState() => ReviewSummaryWidgetState();
}

class ReviewSummaryWidgetState extends State<ReviewSummaryWidget> {
  void _showReviewInput(BuildContext context, double width) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => ReviewInputWidget(
                onReviewSubmit: (double rating, String reviewText) async {
                  await onReviewSubmit(widget.user.user_id, widget.templateId,
                      rating, reviewText);
                },
              )),
    );
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
      num userId, num templateId, double rating, String reviewText) async {
    try {
      if (reviewText.isEmpty) {
        setState(() {
          showToast(context, 'El contenido no puede ser vacío', exitoso: false);
        });
      } else {
        Review review = await addReview(userId, templateId, rating, reviewText);

        setState(() {
          Navigator.pop(context);

          widget.onReviewAdded(review);
        });
      }
    } catch (error) {
      setState(() {
        print('Error al añadir la review: $error');
        Navigator.pop(context);
        showToast(context, 'Ha surgido un error', exitoso: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final width = MediaQuery.of(context).size.width;
    final averageRating = calculateAverageRating(widget.reviews);
    final ratingCount = _calculateRatingCount();
    final maxCount = ratingCount.values
        .fold(0, (prev, element) => element > prev ? element : prev);
    final isReviewed =
        widget.reviews.any((review) => review.userId == widget.user.user_id);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Usa constraints.maxWidth para obtener el ancho disponible
        final width = constraints.maxWidth;

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
      },
    );
  }

  Widget _buildReviewHeader() {
    if (widget.reviews.isEmpty) {
      return const Text(
        'No hay reseñas',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      );
    } else {
      return Container();
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.user.profile_id != adminId
          ? Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Escribir una Reseña'),
                onPressed: () => _showReviewInput(context, width),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                ),
              ),
            )
          : Container(),
    );
  }

  Widget _buildReviewList() {
    List<Review> filteredReviews = widget.reviews.isNotEmpty
        ? widget.reviews
            .where((element) => element.userId == widget.user.user_id)
            .toList()
        : [];

    return widget.reviews.isNotEmpty
        ? ReviewListWidget(
            reviews: filteredReviews.isEmpty
                ? [widget.reviews.first]
                : filteredReviews,
            user: widget.user,
            onReviewDeleted: (int reviewId) {
              setState(() {
                widget.reviews.removeWhere((item) => item.reviewId == reviewId);
                showToast(context, 'Reseña elimianda con éxito');
              });
            },
          )
        : Container();
  }
}
