class TableTennisInfoRegistrationDTO {
  final String racketType;
  final String userLevel;

  TableTennisInfoRegistrationDTO({
    required this.racketType,
    required this.userLevel
  });

  TableTennisInfoRegistrationDTO copyWith({
    String? racketType,
    String? userLevel
  }) {
    return TableTennisInfoRegistrationDTO(
      racketType: racketType ?? this.racketType,
      userLevel: userLevel ?? this.userLevel
    );
  }

  // JSON -> 객체 변환
  factory TableTennisInfoRegistrationDTO.fromJson(Map<String, dynamic> json) {
    return TableTennisInfoRegistrationDTO(
      racketType: json['racketType'] ?? '',
      userLevel: json['userLevel'] ?? ''
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'racketType': racketType,
      'userLevel': userLevel
    };
  }
}