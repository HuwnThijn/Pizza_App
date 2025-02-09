import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class PizzaVideoWidget extends StatefulWidget {
  final String videoUrl;

  const PizzaVideoWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _PizzaVideoWidgetState createState() => _PizzaVideoWidgetState();
}

class _PizzaVideoWidgetState extends State<PizzaVideoWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(20),
      child: _chewieController != null && _videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : Center(child: CircularProgressIndicator()), // Hiện loading khi chưa load xong video
    );
  }
}


