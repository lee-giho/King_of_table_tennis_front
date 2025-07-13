class RegisterDTO {
  final String id;
  final String password;
  final String name;
  final String nickName;
  final String email;
  final String profileImage;

  RegisterDTO({
    required this.id,
    required this.password,
    required this.name,
    required this.nickName,
    required this.email,
    required this.profileImage
  });

  RegisterDTO copyWith({
    String? id,
    String? password,
    String? name,
    String? nickName,
    String? email,
    String? profileImage
  }) {
    return RegisterDTO(
      id: id ?? this.id,
      password: password ?? this.password,
      name: name ?? this.name,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage
    );
  }

  // JSON -> 객체 변환
  factory RegisterDTO.fromJson(Map<String, dynamic> json) {
    return RegisterDTO(
      id: json['id'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      nickName: json['nickName'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? ''
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'name': name,
      'nickName': nickName,
      'email': email,
      'profileImage': profileImage
    };
  }
}