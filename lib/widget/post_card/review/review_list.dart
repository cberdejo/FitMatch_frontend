import 'package:fit_match/widget/expandable_text.dart';
import 'package:fit_match/widget/post_card/star.dart';
import 'package:flutter/material.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/custom_toggle_button.dart';
import 'package:fit_match/widget/text_field_input.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:fit_match/models/review.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/utils.dart';
import 'package:fit_match/services/review_service.dart';

class ReviewListWidget extends StatefulWidget {
  final List<Review> reviews;
  final int userId;
  final bool fullScreen;
  final Function onReviewDeleted; // Callback

  const ReviewListWidget(
      {Key? key,
      required this.reviews,
      required this.userId,
      this.fullScreen = false,
      required this.onReviewDeleted})
      : super(key: key);

  @override
  _ReviewListWidgetState createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  final TextEditingController _textController = TextEditingController();

  Map<num, bool> commentsVisibility = {};
  num? activeReviewId;
  num? activeCommentId;
  num? activeCommentRespondingId;
  String selectedFilter = 'likes';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void onResponderPressed(num reviewId) {
    setState(() {
      activeCommentId = activeCommentId == reviewId ? null : reviewId;
      activeReviewId = activeCommentId;
      // focus
    });
  }

  void onResponderCommentPressed(num commentId) {
    setState(() {
      activeCommentRespondingId =
          activeCommentRespondingId == commentId ? null : commentId;
    });
  }

  void toggleCommentsVisibility(num reviewId) {
    setState(() {
      commentsVisibility[reviewId] = !(commentsVisibility[reviewId] ?? false);
    });
  }

  void _sortReviewsByLikes() {
    widget.reviews.sort((a, b) => b.meGusta.length.compareTo(a.meGusta.length));
  }

  void _sortReviewsByRecent() {
    widget.reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _sortReviewsByHighRating() {
    widget.reviews.sort((a, b) => b.rating.compareTo(a.rating));
  }

  void _sortReviewsByLowRating() {
    widget.reviews.sort((a, b) => a.rating.compareTo(b.rating));
  }

  void _sortReviews(int index) {
    setState(() {
      switch (index) {
        case 0: // Ordenar por 'Me Gusta'
          _sortReviewsByLikes();
          break;
        case 1: // Ordenar por 'Recientes'
          _sortReviewsByRecent();
          break;
        case 2: // Ordenar por 'Calificación Alta'
          _sortReviewsByHighRating();
          break;
        case 3: // Ordenar por 'Calificación Baja'
          _sortReviewsByLowRating();
          break;
      }
    });
  }

  Future<void> _deleteComment(ComentarioReview comment) async {
    try {
      await deleteComment(comment.commentId);
      setState(() {
        widget.reviews
            .firstWhere((item) => item.reviewId == comment.reviewId)
            .comentarioReview
            .removeWhere((item) => item.commentId == comment.commentId);
        showToast(context, 'Comentario eliminado');
      });
    } catch (e) {
      print('Error al eliminar el comentario: $e');
    }
  }

  Future<bool> handleLikeButtonPress(Review review, bool isLiked) async {
    try {
      if (isLiked) {
        // Llamar al backend para quitar el 'me gusta'
        MeGustaReviews likeToDelete =
            await likeReview(widget.userId, review.reviewId);

        // Actualizar el estado con los nuevos 'me gusta' una vez confirmado
        setState(() {
          review.meGusta.removeWhere(
              (item) => item.likedReviewId == likeToDelete.likedReviewId);
        });
      } else {
        // Llamar al backend para dar 'me gusta'
        MeGustaReviews like = await likeReview(widget.userId, review.reviewId);

        // Añadir el 'me gusta' a la lista localmente
        setState(() {
          review.meGusta.add(like);
        });
      }
      return true;
    } catch (e) {
      print('Error al dar o quitar me gusta: $e');
      return false;
    }
  }

  Future<bool> handleLikeCommentButtonPress(
      ComentarioReview comentario, bool isLiked) async {
    try {
      if (isLiked) {
        // Llamar al backend para quitar el 'me gusta'
        MeGustaComentarios likeToDelete =
            await likeComment(widget.userId, comentario.commentId);

        // Actualizar el estado con los nuevos 'me gusta' una vez confirmado
        setState(() {
          comentario.meGusta.removeWhere(
              (item) => item.likedCommentId == likeToDelete.likedCommentId);
        });
      } else {
        // Llamar al backend para dar 'me gusta'
        MeGustaComentarios like =
            await likeComment(widget.userId, comentario.commentId);

        // Añadir el 'me gusta' a la lista localmente
        setState(() {
          comentario.meGusta.add(like);
        });
      }
      return true;
    } catch (e) {
      print('Error al dar o quitar me gusta: $e');
      return false;
    }
  }

  Future<void> onAnswerReview(num userId, Review review, String answer) async {
    try {
      if (answer.trim().isEmpty) {
        setState(() {
          showToast(context, 'El contenido no puede ser vacío');
        });
        return; // Return early to prevent further processing
      }

      ComentarioReview comentarioReview =
          await answerReview(userId, review.reviewId, answer);

      setState(() {
        review.comentarioReview.add(comentarioReview);
        showToast(context, 'Comentario añadido con éxito');

        activeReviewId = null;
        activeCommentId = null;
      });
    } catch (e) {
      print('Error al añadir el comentario: $e');
    }
  }

  Future<void> onAnswerComment(
      num userId, num reviewId, num commentId, String answer) async {
    try {
      if (answer.trim().isEmpty) {
        setState(() {
          showToast(context, 'El contenido no puede ser vacío');
        });
        (context, 'El contenido no puede ser vacío');
      }

      Review review =
          widget.reviews.firstWhere((item) => item.reviewId == reviewId);

      ComentarioReview comentarioReview =
          await answerComment(commentId, userId, review.reviewId, answer);

      setState(() {
        review.comentarioReview.add(comentarioReview);
        showToast(context, 'Comentario añadido con éxito');
      });
    } catch (e) {
      print('Error al añadir la review: $e');
    }
  }

  Future<void> _deleteReview(Review review) async {
    try {
      await deleteReview(review.reviewId);

      setState(() {
        widget.reviews.removeWhere((item) => item.reviewId == review.reviewId);
      });
      widget.onReviewDeleted(review.reviewId);
    } catch (e) {
      print('Error al eliminar la reseña: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullScreen) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reviews',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
        ),
        body: _contentReviews(context),
      );
    } else {
      return _contentReviews(context);
    }
  }

  Widget _contentReviews(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Agregar scroll vertical
      child: Padding(
        padding: widget.fullScreen
            ? const EdgeInsets.all(16.0)
            : const EdgeInsets.all(0),
        child: Column(
          children: [
            Column(
              children: [
                widget.reviews.length > 1
                    ? (width < webScreenSize)
                        ? _buildDropdownFilter()
                        : _buildFilterReviews(context)
                    : Container(),
                const SizedBox(height: 8),
                ...widget.reviews
                    .map((review) => _buildReviewItem(review, width))
                    .toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterReviews(BuildContext context) {
    return Row(
      children: [
        const Text('Ordenar por', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        CustomToggleButtons(
          titles: const [
            'Me Gusta',
            'Recientes',
            'Calificación Alta',
            'Calificación Baja'
          ],
          initialSelection: const [true, false, false, false],
          onToggle: (index) {
            _sortReviews(index);
          },
        )
      ],
    );
  }

  Widget _buildDropdownFilter() {
    return Row(children: [
      const Text('Ordenar por', style: TextStyle(fontSize: 16)),
      const SizedBox(width: 8),
      DropdownButton<String>(
        value: selectedFilter,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedFilter = value;
              if (value == 'likes') {
                _sortReviews(0);
              } else if (value == 'recent') {
                _sortReviews(1);
              } else if (value == 'highRating') {
                _sortReviews(2);
              } else if (value == 'lowRating') {
                _sortReviews(3);
              }
            });
          }
        },
        items: const [
          DropdownMenuItem<String>(
            value: 'likes',
            child: Text('Me Gusta'),
          ),
          DropdownMenuItem<String>(
            value: 'recent',
            child: Text('Recientes'),
          ),
          DropdownMenuItem<String>(
            value: 'highRating',
            child: Text('Calificación Alta'),
          ),
          DropdownMenuItem<String>(
            value: 'lowRating',
            child: Text('Calificación Baja'),
          ),
        ],
      )
    ]);
  }

  Widget _buildReviewItem(Review review, num width) {
    commentsVisibility.putIfAbsent(review.reviewId, () => false);

    return Card(
      margin: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          ListTile(
            title: _buildReviewTitle(review, width),
          ),
          _buildReviewActions(review, width),
          if (activeCommentId == review.reviewId) _buildResponderTextField(),
          if (commentsVisibility[review.reviewId] ?? false)
            _buildCommentsSection(review.comentarioReview, width),
        ],
      ),
    );
  }

  Widget _buildReviewTitle(Review review, num width) {
    final formattedRating = NumberFormat("0.00").format(review.rating);
    final timeAgo = formatTimeAgo(review.timestamp);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(review.profilePicture),
          radius: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  review.username.isNotEmpty
                      ? Text(review.username,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          textScaler: width < webScreenSize
                              ? const TextScaler.linear(0.8)
                              : const TextScaler.linear(1.2))
                      : const Text('Cargando...',
                          style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Text(' - $timeAgo',
                      style: const TextStyle(fontSize: 14),
                      textScaler: width < webScreenSize
                          ? const TextScaler.linear(0.8)
                          : const TextScaler.linear(1.2)),
                ],
              ),
              Wrap(children: [
                StarDisplay(value: review.rating, size: 14),
                const SizedBox(width: 5),
                Text('$formattedRating/5.0',
                    style: const TextStyle(fontSize: 14),
                    textScaler: width < webScreenSize
                        ? const TextScaler.linear(0.8)
                        : const TextScaler.linear(1.2)),
              ]),
              widget.fullScreen
                  ? ExpandableText(
                      text: review.reviewContent,
                      maxLines: 3,
                    )
                  : Text(
                      review.reviewContent,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewActions(Review review, num width) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        _likeButton(review),
        if (review.comentarioReview.isNotEmpty)
          Expanded(
            child: TextButton(
              onPressed: () => toggleCommentsVisibility(review.reviewId),
              child: Text(
                commentsVisibility[review.reviewId]!
                    ? "Ocultar Respuestas"
                    : "Ver ${review.comentarioReview.length} respuestas más",
                style: TextStyle(color: primaryColor),
                textScaler: width < webScreenSize
                    ? const TextScaler.linear(0.8)
                    : const TextScaler.linear(1.2),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        Expanded(
          child: TextButton(
            onPressed: () => onResponderPressed(review.reviewId),
            child: Text(
              activeCommentId == review.reviewId ? "Ocultar" : "Responder",
              style: TextStyle(color: primaryColor),
              textScaler: width < webScreenSize
                  ? const TextScaler.linear(0.8)
                  : const TextScaler.linear(1.2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (review.userId == widget.userId)
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () => _deleteReview(review),
          ),
      ],
    );
  }

  Widget _buildCommentsSection(List<ComentarioReview>? comentarios, num width) {
    return comentarios?.isEmpty ?? true
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: comentarios!
                  .map((comentario) => _buildCommentItem(comentario, width))
                  .toList(),
            ),
          );
  }

  Widget _buildCommentItem(ComentarioReview comentario, num width) {
    final _timeAgo = formatTimeAgo(comentario.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(comentario.profilePicture),
            radius: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    Text(comentario.username,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textScaler: width < webScreenSize
                            ? const TextScaler.linear(0.8)
                            : const TextScaler.linear(1.2)),
                    const SizedBox(width: 4),
                    Text(
                      "-$_timeAgo",
                      style: const TextStyle(fontSize: 14, color: primaryColor),
                      textScaler: width < webScreenSize
                          ? const TextScaler.linear(0.8)
                          : const TextScaler.linear(1.2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExpandableText(
                  text: comentario.content,
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _likeComment(comentario),
                    comentario.userId == widget.userId
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteComment(comentario),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _likeButton(Review review) {
    bool isLiked = review.meGusta.any((item) => item.userId == widget.userId);

    return LikeButton(
      size: 25,
      isLiked: isLiked,
      likeCount: review.meGusta.length,
      onTap: (bool isLiked) async {
        return await handleLikeButtonPress(review, isLiked);
      },
    );
  }

  Widget _likeComment(ComentarioReview comentario) {
    bool isLiked =
        comentario.meGusta.any((like) => like.userId == widget.userId);

    return LikeButton(
      size: 25,
      isLiked: isLiked,
      likeCount: comentario.meGusta.length,
      onTap: (bool isLiked) async {
        return await handleLikeCommentButtonPress(comentario, isLiked);
      },
    );
  }

  Widget _buildResponderTextField() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            // Envolver el TextFieldInput con Expanded
            child: TextFieldInput(
              textEditingController: _textController,
              hintText: 'Escribe un comentario ...',
              textInputType: TextInputType.multiline,
              isPsw: false,
              maxLine: true,
            ),
          ),
          TextButton(
            onPressed: () {
              if (activeReviewId != null) {
                Review activeReview = widget.reviews
                    .firstWhere((review) => review.reviewId == activeReviewId);
                onAnswerReview(
                    widget.userId, activeReview, _textController.text);
                _textController.clear();
              }
            },
            child: Text('Comentar', style: TextStyle(color: primaryColor)),
          )
        ],
      ),
    );
  }
}
