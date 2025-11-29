import 'package:king_of_table_tennis/model/set_score_dto.dart';

class FinishGameRequest {
  final int defenderSetScore;
  final int challengerSetScore;
  final List<SetScoreDto> sets;

  FinishGameRequest({
    required this.defenderSetScore,
    required this.challengerSetScore,
    required this.sets
  });

  factory FinishGameRequest.fromJson(Map<String, dynamic> json) {
    return FinishGameRequest(
      defenderSetScore: json['defenderSetScore'],
      challengerSetScore: json['challengerSetScore'],
      sets: json['sets']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defenderSetScore': defenderSetScore,
      'challengerSetScore': challengerSetScore,
      'sets': sets.map((e) => e.toJson()).toList()
    };
  }
}