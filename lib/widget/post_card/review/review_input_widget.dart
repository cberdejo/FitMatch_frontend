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
    // Usa MediaQuery para obtener la altura del teclado y ajustar el espacio inferior
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text('Escribe tu reseña'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRatingBar(),
              const SizedBox(height: 20),
              _buildReviewTextField(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
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
    return TextField(
      controller: _textController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        hintText: 'Escribe tu reseña aquí',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_textController.text.trim().isNotEmpty) {
          await widget.onReviewSubmit(_currentRating, _textController.text);
          // Puedes cerrar la pantalla después de enviar la reseña si lo deseas
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(
            50), // Establece una altura mínima para el botón
      ),
      child: const Text('Enviar Reseña'),
    );
  }
}
  /*

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
         
        ],
      ),
    );
  }
  */

