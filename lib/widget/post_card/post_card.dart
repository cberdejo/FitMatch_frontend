import 'package:fit_match/services/review_service.dart';
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
  final PlantillaPost post;
  final int userId;

  const PostCard({
    Key? key,
    required this.post,
    required this.userId,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _selectedOption = 'General';
  bool _isLoading = true; // Indicador de carga
  num _averageRating = 0; // Calificación promedio
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviewsAndCalculateRating();
  }

  void _loadReviewsAndCalculateRating() async {
    // Mostrar el indicador de progreso
    setState(() {
      _isLoading = true;
    });

    List<Review> reviews = await getAllReviews(widget.post.templateId);

    if (mounted) {
      {
        setState(() {
          this.reviews = reviews;
          _averageRating = calculateAverageRating(reviews);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildListTile(width),
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

  ListTile _buildListTile(double width) {
    return ListTile(
      title: Text(widget.post.templateName,
          style: TextStyle(fontSize: width > webScreenSize ? 24 : 16)),
      trailing: _isLoading
          ? CircularProgressIndicator() // Muestra el indicador de progreso mientras los datos se están cargando
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(NumberFormat("0.0").format(_averageRating),
                    style: const TextStyle(fontSize: 32)),
                StarDisplay(
                    value: _averageRating.round(),
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
      ),
      child: Image.network(
        widget.post.picture ?? '',
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
              foregroundColor: primaryColor,
              backgroundColor:
                  _selectedOption == option ? blueColor : Colors.grey,
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
  // Obtiene el mapa de secciones cada vez que se construye el widget

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

  ///GENERAL

  Widget _buildGeneralContent() {
    var sectionsMap = widget.post.getSectionsMap();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionsMap['Experiencia']!.isNotEmpty)
          _buildChipsSection(
              'Experiencia Recomendada', sectionsMap['Experiencia']!),
        if (sectionsMap['Disciplinas']!.isNotEmpty)
          _buildChipsSection('Disciplinas Usadas', sectionsMap['Disciplinas']!),
        if (sectionsMap['Objetivos']!.isNotEmpty)
          _buildChipsSection('Objetivos', sectionsMap['Objetivos']!),
        if (sectionsMap['Equipamiento']!.isNotEmpty)
          _buildChipsSection(
              'Equipamiento Necesario', sectionsMap['Equipamiento']!),
        _buildSectionTitle('Descripción'),
        _buildSectionContent(widget.post.description ?? ''),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: ExpandableText(text: content),
    );
  }

  Widget _buildChipsSection(String title, List<dynamic> chipsContent) {
    List<Widget> chips = [];

    // Itera sobre la lista dinámica y agrega un Chip solo para los elementos que son String
    for (var content in chipsContent) {
      if (content is String) {
        chips.add(Chip(
          label: Text(content),
          backgroundColor: blueColor,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Wrap(
          spacing: 8.0,
          children: chips,
        ),
      ],
    );
  }

//REVIEWS
  Widget _buildReviewsContent() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ReviewSummaryWidget(
              reviews: reviews,
              userId: widget.userId,
              templateId: widget.post.templateId,
              onReviewAdded: (Review review) {
                //se añade en local en vez de obtener todas de nuevo
                setState(() {
                  reviews.add(review);
                });
              }),
        ),
        Row(
          children: [
            const SizedBox(width: 24),
            reviews.length > 1
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
                    reviews: reviews,
                    userId: widget.userId,
                    onReviewDeleted: (int reviewId) {
                      setState(() {
                        reviews
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
