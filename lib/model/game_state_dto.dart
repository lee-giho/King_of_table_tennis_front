import 'package:king_of_table_tennis/enum/game_state.dart';

class GameStateDTO {
  final String gameInfoId;
  final String defenderId;
  final String challengerId;
  final int defenderScore;
  final int challengerScore;
  final GameState state;

  GameStateDTO({
    required this.gameInfoId,
    required this.defenderId,
    required this.challengerId,
    required this.defenderScore,
    required this.challengerScore,
    required this.state,
  });

  factory GameStateDTO.fromJson(Map<String, dynamic> json) {
    return GameStateDTO(
      gameInfoId: json['gameInfoId'],
      defenderId: json['defenderId'],
      challengerId: json['challengerId'] ?? '',
      defenderScore: json['defenderScore'] ?? 0,
      challengerScore: json['challengerScore'] ?? 0,
      state: GameStateExtension.fromString(json['state'])
    );
  }
}