class GameRegistrationDTO {
  final int gameSet;
  final int gameScore;
  final String place;
  final String acceptanceType;
  final DateTime gameDate;

  GameRegistrationDTO({
    required this.gameSet,
    required this.gameScore,
    required this.place,
    required this.acceptanceType,
    required this.gameDate
  });

  GameRegistrationDTO copyWith({
    int? gameSet,
    int? gameScore,
    String? place,
    String? acceptanceType,
    DateTime? gameDate
  }) {
    return GameRegistrationDTO(
      gameSet: gameSet ?? this.gameSet,
      gameScore: gameScore ?? this.gameScore,
      place: place ?? this.place,
      acceptanceType: acceptanceType ?? this.acceptanceType,
      gameDate: gameDate ?? this.gameDate
    );
  }

  // JSON -> 객체 변환
  factory GameRegistrationDTO.fromJson(Map<String, dynamic> json) {
    return GameRegistrationDTO(
      gameSet: json['gameSet'] ?? 0,
      gameScore: json['gameScore'] ?? 0,
      place: json['place'] ?? '',
      acceptanceType: json['acceptanceType'] ?? '',
      gameDate: DateTime.tryParse(json['gameDate'] ?? '') ?? DateTime.now()
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'gameSet': gameSet,
      'gameScore': gameScore,
      'place': place,
      'acceptanceType': acceptanceType,
      'gameDate': gameDate.toIso8601String()
    };
  }
}