import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:king_of_table_tennis/model/video_info.dart';
import 'package:king_of_table_tennis/widget/customDivider.dart';
import 'package:king_of_table_tennis/widget/customYoutubePlayer.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeVideoListScreen extends StatefulWidget {
  final String youtubePlaylistId;

  const YoutubeVideoListScreen({
    super.key,
    required this.youtubePlaylistId
  });

  @override
  State<YoutubeVideoListScreen> createState() => _YoutubeVideoListScreenState();
}

class _YoutubeVideoListScreenState extends State<YoutubeVideoListScreen> {
  
  static const int pageSize = 5;

  final List<VideoInfo> videos = [];
  late YoutubeExplode yt;
  StreamIterator<Video>? videoIterator;

  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    yt = YoutubeExplode();
    videoIterator = StreamIterator(yt.playlists.getVideos(widget.youtubePlaylistId));

    handleLoadYoutubeVideos();
  }

  @override
  void dispose() {
    videoIterator?.cancel();
    yt.close();
    super.dispose();
  }

  Future<void> handleLoadYoutubeVideos() async {
    log("[get]");
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    int fetched = 0;

    try {
      while (fetched < pageSize && await videoIterator!.moveNext()) {
        final video = videoIterator!.current;

        videos.add(
          VideoInfo(
            id: video.id.value,
            title: video.title
          )
        );
        fetched++;
      }

      if (fetched < pageSize) {
        hasMore = false;
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "영상 목록을 불러오는 중 오류가 발생했습니다.";
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;  
      });
    }
  }

  Widget buildBody() {
    if (videos.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator()
      );
    }

    if (videos.isEmpty && errorMessage != null) {
      return Center(
        child: Text(errorMessage!)
      );
    }

    if (videos.isEmpty) {
      return const Center(
        child: Text("불러올 영상이 없습니다.")
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: videos.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == videos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(),
            )
          );
        }

        final video = videos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              CustomYoutubePlayer(
                videoInfo: video
              ),
              CustomDivider()
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "관련 영상",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200 &&
              !isLoading &&
              hasMore) {
                handleLoadYoutubeVideos();
          }
          return false;
        },
        child: buildBody()
      )
    );
  }
}