import 'package:king_of_table_tennis/model/game_info.dart';

class RecruitingGameDTO {
  final GameInfo gameInfo;
  final String creatorId;
  final String gameState;

  RecruitingGameDTO({
    required this.gameInfo,
    required this.creatorId,
    required this.gameState
  });

  // JSON -> 객체 변환
  factory RecruitingGameDTO.fromJson(Map<String, dynamic> json) {
    return RecruitingGameDTO(
      gameInfo: GameInfo.fromJson(json['gameInfo']),
      creatorId: json['creatorId'],
      gameState: json['gameState']
    );
  }
}