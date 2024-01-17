import 'package:fit_match/widget/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewInputWidget extends StatefulWidget {
  final Future<void> Function(double rating, String reviewText) onReviewSubmit;

  const ReviewInputWidget({Key? key, required this.onReviewSubmit})
      : super(key: key);

  @override
  _ReviewInputWidgetState createState() => _ReviewInputWidgetState();
}

class _ReviewInputWidgetState extends State<ReviewInputWidget> {
  final TextEditingController _textController = TextEditingController();
  double _currentRating = 3; // Valor inicial de la calificación

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRatingBar(),
          const SizedBox(height: 8),
          _buildReviewTextField(),
          const SizedBox(height: 8),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        const Text("Calificación: "),
        const SizedBox(width: 8),
        RatingBar.builder(
          initialRating: _currentRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) {
            setState(() {
              _currentRating = rating;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return TextFieldInput(
      textEditingController: _textController,
      hintText: 'Escribe tu reseña aquí',
      textInputType: TextInputType.multiline,
      isPsw: false,
      maxLine: true,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_textController.text.trim().isNotEmpty) {
          await widget.onReviewSubmit(_currentRating, _textController.text);
        } else {}
      },
      child: const Text('Enviar Reseña'),
    );
  }
}
