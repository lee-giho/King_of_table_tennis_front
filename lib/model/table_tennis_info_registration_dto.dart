class TableTennisInfoRegistrationDTO {
  final String racketType;
  final String level;

  TableTennisInfoRegistrationDTO({
    required this.racketType,
    required this.level
  });

  TableTennisInfoRegistrationDTO copyWith({
    String? racketType,
    String? level
  }) {
    return TableTennisInfoRegistrationDTO(
      racketType: racketType ?? this.racketType,
      level: level ?? this.level
    );
  }

  // JSON -> 객체 변환
  factory TableTennisInfoRegistrationDTO.fromJson(Map<String, dynamic> json) {
    return TableTennisInfoRegistrationDTO(
      racketType: json['racketType'] ?? '',
      level: json['level'] ?? ''
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'racketType': racketType,
      'level': level
    };
  }
}