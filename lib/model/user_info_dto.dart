class UserInfoDTO {
  final String id;
  final String name;
  final String nickName;
  final String email;
  final String profileImage;
  final String racketType;

  UserInfoDTO({
    required this.id,
    required this.name,
    required this.nickName,
    required this.email,
    required this.profileImage,
    required this.racketType,
  });

  factory UserInfoDTO.fromJson(Map<String, dynamic> json) {
    return UserInfoDTO(
      id: json['id'],
      name: json['name'],
      nickName: json['nickName'],
      email: json['email'],
      profileImage: json['profileImage'],
      racketType: json['racketType'],
    );
  }

  factory UserInfoDTO.empty() {
    return UserInfoDTO(
      id: '',
      name: '',
      nickName: '',
      email: '',
      profileImage: '',
      racketType: ''
    );
  }
}