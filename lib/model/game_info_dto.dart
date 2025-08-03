class GameInfoDTO {
  final String id;
  final int gameSet;
  final int gameScore;
  final String place;
  final String acceptanceType;
  final DateTime gameDate;

  GameInfoDTO({
    required this.id,
    required this.gameSet,
    required this.gameScore,
    required this.place,
    required this.acceptanceType,
    required this.gameDate,
  });

  factory GameInfoDTO.fromJson(Map<String, dynamic> json) {
    return GameInfoDTO(
      id: json['id'],
      gameSet: json['gameSet'],
      gameScore: json['gameScore'],
      place: json['place'],
      acceptanceType: json['acceptanceType'],
      gameDate: DateTime.parse(json['gameDate']),
    );
  }
}