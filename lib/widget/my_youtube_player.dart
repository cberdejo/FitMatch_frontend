import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MyYoutubePlayer extends StatefulWidget {
  final String uri;
  const MyYoutubePlayer({super.key, required this.uri});
  @override
  MyYoutubePlayerState createState() => MyYoutubePlayerState();
}

class MyYoutubePlayerState extends State<MyYoutubePlayer> {
  late YoutubePlayerController _controller;

  String? extractYoutubeVideoId(String url) {
    final Uri uri = Uri.tryParse(url) ?? Uri();

    // URL estándar de YouTube: https://www.youtube.com/watch?v=dQw4w9WgXcQ
    if (uri.host == 'www.youtube.com' || uri.host == 'youtube.com') {
      return uri.queryParameters['v'];
    }
    // URL corta de YouTube: https://youtu.be/dQw4w9WgXcQ
    else if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    }
    // URL de incrustación de YouTube: https://www.youtube.com/embed/dQw4w9WgXcQ
    else if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'embed') {
      return uri.pathSegments[1];
    }

    // No coincide con ningún formato conocido
    return null;
  }

  @override
  void initState() {
    super.initState();
    final videoId = extractYoutubeVideoId(widget.uri);
    if (videoId == null) {
      throw Exception('No se ha podido extraer el videoId de ${widget.uri}');
    }
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        loop: true,
      ),
    );
    _controller.setFullScreenListener(
      (isFullScreen) {},
    );
    _controller.loadVideoById(videoId: videoId);
    // _controller.cueVideoById(videoId: videoId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.all(8),
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }

  @override
  void dispose() {
    _controller.pauseVideo();
    _controller.close();
    super.dispose();
  }
}
