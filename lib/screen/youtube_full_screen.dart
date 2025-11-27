import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeFullScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final Duration startAt;

  const YoutubeFullScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.startAt
  });

  @override
  State<YoutubeFullScreen> createState() => _YoutubeFullScreenState();
}

class _YoutubeFullScreenState extends State<YoutubeFullScreen> {

  late YoutubePlayerController youtubePlayerController;

  @override
  void initState() {
    super.initState();

    youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        startAt: widget.startAt.inSeconds,
        
      )
    );

  }

  @override
  void dispose() {
    youtubePlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: youtubePlayerController,
        showVideoProgressIndicator: true,
        topActions: <Widget>[
          IconButton(
            onPressed: () {
              print("object");
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.close,
              color: Colors.white
            )
          )
        ],
        bottomActions: const [
          SizedBox(width: 14),
          CurrentPosition(),
          SizedBox(width: 8),
          ProgressBar(isExpanded: true),
          SizedBox(width: 8),
          RemainingDuration()
        ]
      ),
      builder: (context, player) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            return SafeArea(
              child: Scaffold(
                body: isLandscape
                  ? Center(
                      child: player
                    )
                  : Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: player,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                            child: Column(
                              children: [
                                Text(
                                  widget.videoTitle,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                CustomDivider()
                              ],
                            ),
                          )
                        )
                      ],
                    )
              ),
            );
          }
        );
      }
    );
  }
}