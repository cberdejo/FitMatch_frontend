import 'package:flutter/material.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/models/post.dart';
import 'package:fit_match/widget/expandable_text.dart';
import '../../models/review.dart';
import 'review/review_list.dart';
import 'review/review_summary.dart';
import 'star.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final int userId;
  final int clientId;

  const PostCard(
      {Key? key,
      required this.post,
      required this.userId,
      required this.clientId})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _selectedOption = 'General';

  @override
  Widget build(BuildContext context) {
    final formattedAverage =
        NumberFormat("0.0").format(calculateAverageRating(widget.post.reviews));
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: 400,
      child: Card(
        color:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        surfaceTintColor:
            width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            _buildListTile(formattedAverage, width),
            const SizedBox(height: 12),
            _buildPostImage(width),
            const SizedBox(height: 12),
            _buildSelectButtons(),
            const SizedBox(height: 12),
            _buildContentBasedOnSelection(),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile(String formattedAverage, double width) {
    return ListTile(
      title: Text(widget.post.username,
          style: TextStyle(fontSize: width > webScreenSize ? 24 : 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formattedAverage, style: const TextStyle(fontSize: 32)),
          StarDisplay(
              value: calculateAverageRating(widget.post.reviews),
              size: width > webScreenSize ? 48 : 16),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Container _buildPostImage(double width) {
    return Container(
      width: width > webScreenSize ? 500 : 250,
      height: width > webScreenSize ? 500 : 250,
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor, width: 2),
        // Image code commented out
      ),
    );
  }

  Widget _buildSelectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['General', 'Reviews', 'Información'].map((option) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _selectedOption == option ? blueColor : Colors.grey,
              onPrimary: Colors.white,
            ),
            onPressed: () => _onSelectOption(option),
            child: Text(option),
          ),
        );
      }).toList(),
    );
  }

  void _onSelectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  Widget _buildContentBasedOnSelection() {
    switch (_selectedOption) {
      case 'General':
        return _buildGeneralContent();
      case 'Reviews':
        return _buildReviewsContent();
      default:
        return Container(); // Placeholder for 'Información' content
    }
  }

  Column _buildGeneralContent() {
    return Column(
      children: [
        const Text('Sobre mí',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ExpandableText(text: widget.post.description),
        ),
      ],
    );
  }

  Column _buildReviewsContent() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ReviewSummaryWidget(
              reviews: widget.post.reviews,
              userId: widget.userId,
              clientId: widget.clientId,
              trainerId: widget.post.trainerId,
              onReviewAdded: (Review review) {
                setState(() {
                  widget.post.reviews.add(review);
                });
              }),
        ),
        Row(
          children: [
            const SizedBox(width: 24),
            widget.post.reviews.length > 1
                ? TextButton(
                    onPressed: _showDialog,
                    child: const Text("Ver todas las reseñas"))
                : Container(),
          ],
        ),
      ],
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              if (_selectedOption == 'Reviews')
                ReviewListWidget(
                    reviews: widget.post.reviews,
                    userId: widget.userId,
                    clientId: widget.clientId,
                    onReviewDeleted: (int reviewId) {
                      setState(() {
                        widget.post.reviews
                            .removeWhere((item) => item.reviewId == reviewId);
                        showToast(context, 'Reseña elimianda con éxito');
                      });
                    }),
              // Placeholder for 'Información' content
              Positioned(
                right: -10.0,
                top: -10.0,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30.0),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
