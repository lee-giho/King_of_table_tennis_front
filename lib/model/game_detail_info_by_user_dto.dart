import 'package:king_of_table_tennis/model/game_info_dto.dart';
import 'package:king_of_table_tennis/model/game_state_dto.dart';
import 'package:king_of_table_tennis/model/user_info_dto.dart';

class GameDetailInfoByUserDTO {
  final UserInfoDTO defenderInfo;
  final UserInfoDTO challengerInfo;
  final GameInfoDTO gameInfo;
  final GameStateDTO gameState;
  final bool isMine;
  final int applicationCount;
  final bool hasReviewed;

  GameDetailInfoByUserDTO({
    required this.defenderInfo,
    required this.challengerInfo,
    required this.gameInfo,
    required this.gameState,
    required this.isMine,
    required this.applicationCount,
    required this.hasReviewed
  });

  factory GameDetailInfoByUserDTO.fromJson(Map<String, dynamic> json) {
    return GameDetailInfoByUserDTO(
      defenderInfo: json['defenderInfo'] != null
        ? UserInfoDTO.fromJson(json['defenderInfo'])
        : UserInfoDTO.empty(),
      challengerInfo: json['challengerInfo'] != null
        ? UserInfoDTO.fromJson(json['challengerInfo'])
        : UserInfoDTO.empty(),
      gameInfo: GameInfoDTO.fromJson(json['gameInfo']),
      gameState: GameStateDTO.fromJson(json['gameState']),
      isMine: json['mine'],
      applicationCount: json['applicationCount'],
      hasReviewed: json['hasReviewed']
    );
  }
}