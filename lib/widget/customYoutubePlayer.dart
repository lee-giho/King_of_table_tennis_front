import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/video_info.dart';
import 'package:king_of_table_tennis/screen/youtube_full_screen.dart';
import 'package:king_of_table_tennis/widget/expandableTitle.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CustomYoutubePlayer extends StatefulWidget {
  final VideoInfo videoInfo;
  final bool enableExpand;

  const CustomYoutubePlayer({
    super.key,
    required this.videoInfo,
    this.enableExpand = true
  });

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {

  late YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    super.initState();

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoInfo.id,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: false
      )
    );
  }

  @override
  void dispose() {
    youtubePlayerController.dispose();
    
    super.dispose();
  }

  void openFullScreen() {
    final currentPosition = youtubePlayerController.value.position;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YoutubeFullScreen(
          videoId: widget.videoInfo.id,
          videoTitle: widget.videoInfo.title,
          startAt: currentPosition
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              YoutubePlayer(
                controller: youtubePlayerController,
                showVideoProgressIndicator: true,
                bottomActions: const [
                  SizedBox(width: 14),
                  CurrentPosition(),
                  SizedBox(width: 8),
                  ProgressBar(isExpanded: true),
                  SizedBox(width: 8),
                  RemainingDuration()
                ],
              ),
              Positioned(
                right: 8,
                bottom: 10,
                child: IconButton(
                  onPressed: () {
                    openFullScreen();
                  },
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white
                  )
                )
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: widget.enableExpand
            ? ExpandableTitle(
                text: widget.videoInfo.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              )
            : Text(
                widget.videoInfo.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis
                ),
              )
        )
      ],
    );
  }
}