import 'package:fit_match/models/post.dart';
import 'package:fit_match/utils/colors.dart';
import 'package:fit_match/utils/dimensions.dart';
import 'package:fit_match/widget/chip_section.dart';
import 'package:fit_match/widget/post_card/star.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildPostItem(PlantillaPost post, double width,
    {VoidCallback? showPost, Widget? trailing}) {
  final formattedRating = NumberFormat("0.00").format(post.ratingAverage);
  var sectionsMap = post.getSectionsMap();

  return MouseRegion(
    cursor:
        showPost != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: showPost,
      child: Card(
        //width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: width > webScreenSize ? 250 : 100,
                    height: width > webScreenSize ? 250 : 100,
                    child: Image.network(
                      post.picture ?? '',
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.templateName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: width < webScreenSize
                              ? const TextScaler.linear(1)
                              : const TextScaler.linear(1.5),
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hecho por ${post.username}',
                          maxLines: 1,
                          textScaler: width < webScreenSize
                              ? const TextScaler.linear(1)
                              : const TextScaler.linear(1.5),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        if (sectionsMap['Experiencia']!.isNotEmpty)
                          buildChipsSection(null, sectionsMap['Experiencia']),
                        const SizedBox(height: 10),
                        post.ratingAverage != null
                            ? StarDisplay(
                                value: post.ratingAverage!,
                                size: width < webScreenSize ? 14 : 20)
                            : Container(),
                        Wrap(
                          children: [
                            Text(
                              '$formattedRating/5.0',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              textScaler: width < webScreenSize
                                  ? const TextScaler.linear(1)
                                  : const TextScaler.linear(1.5),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '(${post.numReviews} reseñas)',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              textScaler: width < webScreenSize
                                  ? const TextScaler.linear(1)
                                  : const TextScaler.linear(1.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            )
          ],
        ),
      ),
    ),
  );
}
