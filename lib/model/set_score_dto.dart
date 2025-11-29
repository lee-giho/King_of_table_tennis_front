class SetScoreDto {
  final int setNumber;
  final int defenderScore;
  final int challengerScore;

  SetScoreDto({
    required this.setNumber,
    required this.defenderScore,
    required this.challengerScore
  });

  factory SetScoreDto.fromJson(Map<String, dynamic> json) {
    return SetScoreDto(
      setNumber: json['setNumber'],
      defenderScore: json['defenderScore'],
      challengerScore: json['challengerScore']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'defenderScore': defenderScore,
      'challengerScore': challengerScore
    };
  }
}