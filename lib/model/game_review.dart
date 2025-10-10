import 'package:king_of_table_tennis/model/game_info_dto.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class GameReview {
  final String id;
  final UserInfoDTO reviewee;
  final GameInfoDTO gameInfo;

  final int scoreServe;
  final int scoreReceive;
  final int scoreRally;
  final int scoreStrokes;
  final int scoreStrategy;

  final int scoreManner;
  final int scorePunctuality;
  final int scoreCommunity;
  final int scorePoliteness;
  final int scoreRematch;

  final String comment;

  final DateTime writeDate;


  GameReview({
    required this.id,
    required this.reviewee,
    required this.gameInfo,
    required this.scoreServe,
    required this.scoreReceive,
    required this.scoreRally,
    required this.scoreStrokes,
    required this.scoreStrategy,
    required this.scoreManner,
    required this.scorePunctuality,
    required this.scoreCommunity,
    required this.scorePoliteness,
    required this.scoreRematch,
    required this.comment,
    required this.writeDate
  });

  factory GameReview.fromJson(Map<String, dynamic> json) {
    return GameReview(
      id: json['id'],
      reviewee: json['reviewee'] != null
        ? UserInfoDTO.fromJson(json['reviewee'])
        : UserInfoDTO.empty(),
      gameInfo: GameInfoDTO.fromJson(json['gameInfo']),
      scoreServe: json['scoreServe'],
      scoreReceive: json['scoreReceive'],
      scoreRally: json['scoreRally'],
      scoreStrokes: json['scoreStrokes'],
      scoreStrategy: json['scoreStrategy'],
      scoreManner: json['scoreManner'],
      scorePunctuality: json['scorePunctuality'],
      scoreCommunity: json['scoreCommunity'],
      scorePoliteness: json['scorePoliteness'],
      scoreRematch: json['scoreRematch'],
      comment: json['comment'],
      // writeDate: DateTime.tryParse(json['gameDate'] ?? '') ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour+1)
      writeDate: DateTime.tryParse(json['writeDate'] ?? '')
        ?.toLocal() ?? DateTime.now()
    );
  }
}