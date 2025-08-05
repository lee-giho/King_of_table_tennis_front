class UserInfoDTO {
  final String id;
  final String name;
  final String nickName;
  final String email;
  final String profileImage;
  final String racketType;
  final String userLevel;
  final int winCount;
  final int defeatCount;

  UserInfoDTO({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.profileImage,
    required this.racketType,
    required this.userLevel,
    required this.winCount,
    required this.defeatCount
  });

  factory UserInfoDTO.fromJson(Map<String, dynamic> json) {
    return UserInfoDTO(
      id: json['id'],
      name: json['name'],
      nickName: json['nickName'],
      email: json['email'],
      profileImage: json['profileImage'],
      racketType: json['racketType'],
      userLevel: json['userLevel'],
      winCount: json['winCount'],
      defeatCount: json['defeatCount']
    );
  }

  factory UserInfoDTO.empty() {
    return UserInfoDTO(
      id: '',
      name: '',
      nickName: '',
      email: '',
      profileImage: '',
      racketType: '',
      userLevel: '',
      winCount: 0,
      defeatCount: 0
    );
  }
}