import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Unit8ImageDetail extends StatelessWidget {
  final Uint8List imageData;

  const Unit8ImageDetail({Key? key, required this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Imagen en detalle"),
      ),
      body: Center(
        child: Image.memory(imageData),
      ),
    );
  }
}

class ImageDetail extends StatelessWidget {
  final String imageData;

  const ImageDetail({Key? key, required this.imageData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Imagen en detalle"),
      ),
      body: Center(
        child: Image.network(imageData),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final String videoPath;
  final VoidCallback onDeleteVideo;

  const VideoDetailScreen({
    Key? key,
    required this.videoPath,
    required this.onDeleteVideo,
  }) : super(key: key);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Determina la fuente del controlador según la plataforma
    if (kIsWeb) {
      // Para la web, usa una URL
      _controller = VideoPlayerController.network(widget.videoPath);
    } else {
      // Para móviles, usa un archivo
      _controller = VideoPlayerController.file(File(widget.videoPath));
    }

    _controller.initialize().then((_) {
      setState(() {}); // Actualiza la UI cuando el video esté listo
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video en detalle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.onDeleteVideo();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
