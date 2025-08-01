class GameInfo {
  final String id;
  final int gameSet;
  final int gameScore;
  final String place;
  final String acceptanceType;
  final DateTime gameDate;

  GameInfo({
    required this.id,
    required this.gameSet,
    required this.gameScore,
    required this.place,
    required this.acceptanceType,
    required this.gameDate,
  });

  factory GameInfo.fromJson(Map<String, dynamic> json) {
    return GameInfo(
      id: json['id'],
      gameSet: json['gameSet'],
      gameScore: json['gameScore'],
      place: json['place'],
      acceptanceType: json['acceptanceType'],
      gameDate: DateTime.parse(json['gameDate']),
    );
  }
}