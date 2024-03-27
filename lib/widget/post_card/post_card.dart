import 'package:fit_match/models/sesion_entrenamiento.dart';
import 'package:fit_match/models/user.dart';
import 'package:fit_match/screens/client/training/register_training/register_training.dart';
import 'package:fit_match/services/plantilla_posts_service.dart';
import 'package:fit_match/services/registro_service.dart';
import 'package:fit_match/services/review_service.dart';
import 'package:fit_match/widget/chip_section.dart';
import 'package:fit_match/widget/custom_button_session.dart';
import 'package:fit_match/widget/exercise_card/overviewPlantilla.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/models/post.dart';
import 'package:fit_match/widget/expandable_text.dart';
import '../../models/review.dart';
import 'review/review_list.dart';
import 'review/review_summary.dart';
import 'star.dart';

class PostCard extends StatefulWidget {
  final PlantillaPost post;
  final User user;

  const PostCard({
    Key? key,
    required this.post,
    required this.user,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _selectedOption = 'General';
  bool _isLoading = true; // Indicador de carga general
  bool _isLoadingActivePost = true; //Indicador de carga para el botón de activo
  num _averageRating = 0; // Calificación promedio
  List<Review> reviews = [];
  PlantillaPost? postActivo;

  SesionEntrenamiento? _lastSessionRegistrada;
  bool _lastSessionIsFinished = false;

  @override
  void initState() {
    super.initState();
    _loadReviewsAndCalculateRating();
    _checkIfIsActive();
    _loadLastRegister();
  }

  bool _isActive() {
    return postActivo != null && postActivo?.hidden == false;
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

  void _loadLastRegister() async {
    try {
      Map<String, dynamic> lastRegister = await RegistroMethods()
          .getLastRegistersByUserIdAndTemplateId(
              widget.user.user_id as int, widget.post.templateId);
      setState(() {
        _lastSessionRegistrada = lastRegister['sesion'];
        _lastSessionIsFinished = lastRegister['finished'];
      });
    } catch (e) {
      print(e);
    }
  }

  _checkIfIsActive() async {
    try {
      List<PlantillaPost> plantillas =
          await RutinaGuardadaMethods().getPlantillas(widget.user.user_id);
      setState(() {
        postActivo = plantillas.firstWhere(
          (element) => element.templateId == widget.post.templateId,
        );
      });
      //print(postActivo?.hidden);
    } catch (e) {
      //postActivo es nulo
    } finally {
      setState(() {
        _isLoadingActivePost = false;
      });
    }
  }

  void _onSelectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _showReviews() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReviewListWidget(
            reviews: reviews,
            userId: widget.user.user_id,
            fullScreen: true,
            onReviewDeleted: (int reviewId) {
              setState(() {
                reviews.removeWhere((item) => item.reviewId == reviewId);
                showToast(context, 'Reseña elimianda con éxito');
              });
            }),
      ),
    );
  }

  void _activarPlantilla() async {
    try {
      if (_isLoadingActivePost) return;

      _isLoadingActivePost = true;
      bool exito = false;

      if (_isActive()) {
        //ha de existir un postActivo y no estar oculto

        // se esconde
        exito = await PlantillaPostsMethods().toggleHidden(
            widget.post.templateId, "guardadas",
            userId: widget.user.user_id);

        //No existe o está oculto
      } else {
        //si no existe lo guardo
        if (postActivo == null) {
          exito = await PlantillaPostsMethods()
              .guardar(widget.post.templateId, widget.user.user_id);
        } else {
          // si ya existe significa que está oculto, debo mostrarlo
          exito = await PlantillaPostsMethods().toggleHidden(
              widget.post.templateId, "guardadas",
              userId: widget.user.user_id);
        }
      }

      if (exito) {
        if (postActivo == null) {
          await _checkIfIsActive();
        } else {
          setState(() {
            postActivo?.hidden = postActivo!.hidden ? false : true;
            _isLoadingActivePost = false;
          });
        }
      } else {
        showToast(context, "Ha ocurrido un error.", exitoso: false);
      }
    } catch (e) {
      showToast(context, 'Ha ocurrido un error ', exitoso: false);
    }
  }

  _navigateToRegisterSession() async {
    if (!_isActive()) {
      _activarPlantilla();
    }
    if (_lastSessionRegistrada != null) {
      final reload = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RegisterTrainingScreen(
          user: widget.user,
          sessionId: _lastSessionRegistrada!.sessionId,
        ),
      ));

      if (reload == true) {
        _loadLastRegister();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final String StateRegister =
        _lastSessionIsFinished ? 'Empezar sesión ' : 'Continuar con sesión';
    final String buttonTextName = _lastSessionRegistrada != null
        ? _lastSessionRegistrada!.sessionName
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plantilla de entrenamiento"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Card(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(children: [
                            const SizedBox(height: 12),
                            _buildListTile(width),
                            const SizedBox(height: 12),
                            _buildPostImage(width),
                            const SizedBox(height: 12),
                            _buildSelectButtons(),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        _buildContentBasedOnSelection(width),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_lastSessionRegistrada != null)
            Positioned(
              bottom: 10, // Ajusta la distancia desde el fondo de la pantalla
              left: 0,
              right: 0,
              child: CustomButtonSession(
                  icon: Icons.sports_gymnastics_outlined,
                  onTap: () => {_navigateToRegisterSession()},
                  text: '$StateRegister $buttonTextName'),
            ),
        ],
      ),
    );
  }

  ListTile _buildListTile(double width) {
    return ListTile(
      title: Text(widget.post.templateName,
          style: TextStyle(fontSize: width > webScreenSize ? 24 : 16)),
      trailing: _isLoading
          ? const CircularProgressIndicator() // Muestra el indicador de progreso mientras los datos se están cargando
          : Wrap(
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
        border:
            Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: Image.network(
        widget.post.picture ?? '',
      ),
    );
  }

  Widget _buildSelectButtons() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    return Row(children: [
      ...['General', 'Reseñas', 'Info'].map((option) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor:
                    _selectedOption == option ? primaryColor : Colors.grey,
              ),
              onPressed: () => _onSelectOption(option),
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(color: onPrimaryColor),
              ),
            ),
          ),
        );
      }).toList(),
      if (!_isLoadingActivePost)
        IconButton(
            onPressed: () => _activarPlantilla(),
            icon: _isActive()
                ? Icon(
                    Icons.bookmark_added_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )
                : Icon(
                    Icons.bookmark_border_rounded,
                    color: Theme.of(context).primaryColor,
                  ))
    ]);
  }

  // Obtiene el mapa de secciones cada vez que se construye el widget

  Widget _buildContentBasedOnSelection(num width) {
    switch (_selectedOption) {
      case 'General':
        return _buildGeneralContent();
      case 'Reseñas':
        return _buildReviewsContent(width);

      case 'Info':
        return OverviewPlantilla(
            user: widget.user,
            templateId: widget.post.templateId,
            templateName: widget.post.templateName);
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
          buildChipsSection(
              'Experiencia Recomendada', sectionsMap['Experiencia']!),
        if (sectionsMap['Disciplinas']!.isNotEmpty)
          buildChipsSection('Disciplinas Usadas', sectionsMap['Disciplinas']!),
        if (sectionsMap['Objetivos']!.isNotEmpty)
          buildChipsSection('Objetivos', sectionsMap['Objetivos']!),
        if (sectionsMap['Equipamiento']!.isNotEmpty)
          buildChipsSection(
              'Equipamiento Necesario', sectionsMap['Equipamiento']!),
        if (sectionsMap['Duracion']!.isNotEmpty)
          buildChipsSection('Duración', sectionsMap['Duracion']!),
        buildSectionTitle('Descripción'),
        _buildSectionContent(widget.post.description ?? ''),
      ],
    );
  }

  Widget _buildSectionContent(String content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      child: ExpandableText(text: content),
    );
  }

//REVIEWS
  Widget _buildReviewsContent(num width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            const SizedBox(width: 24),
            reviews.length > 1
                ? TextButton(
                    onPressed: _showReviews,
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    child: Text(
                      "Ver todas las reseñas",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14),
                      textScaler: width < webScreenSize
                          ? const TextScaler.linear(0.9)
                          : const TextScaler.linear(1.2),
                    ),
                  )
                : Container(),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
          child: ReviewSummaryWidget(
              reviews: reviews,
              userId: widget.user.user_id,
              templateId: widget.post.templateId,
              onReviewAdded: (Review review) {
                //se añade en local en vez de obtener todas de nuevo
                setState(() {
                  reviews.add(review);
                  showToast(context, 'Reseña anadida con exito');
                });
              }),
        ),
      ],
    );
  }
}
