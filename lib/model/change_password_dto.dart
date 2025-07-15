class ChangePasswordDTO {
  final String id;
  final String password;
  final String name;
  final String email;

  ChangePasswordDTO({
    required this.id,
    required this.password,
    required this.name,
    required this.email
  });

  ChangePasswordDTO copyWith({
    String? id,
    String? password,
    String? name,
    String? email
  }) {
    return ChangePasswordDTO(
      id: id ?? this.id,
      password: password ?? this.password,
      name: name ?? this.name,
      email: email ?? this.email
    );
  }

  // JSON -> 객체 변환
  factory ChangePasswordDTO.fromJson(Map<String, dynamic> json) {
    return ChangePasswordDTO(
      id: json['id'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? ''
    );
  }

  // 객체 -> JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'name': name,
      'email': email
    };
  }
}