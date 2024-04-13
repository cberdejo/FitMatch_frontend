import 'package:fit_match/widget/my_youtube_player.dart';
import 'package:flutter/material.dart';

Widget buildInfoWidget(String name, String? description,
    String? previewImageUrl, String? youtubeUrl) {
  return Column(
    children: [
      Text(
        name,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(description ?? ''),
      if (previewImageUrl != null)
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Image.asset("assets/images/muscle_groups/$previewImageUrl.png",
              height: 100),
        ),
      if (youtubeUrl != null && youtubeUrl.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: MyYoutubePlayer(uri: youtubeUrl),
        ),
    ],
  );
}
