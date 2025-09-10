class MySimpleInfo {
  final String nickName;
  final String profileImage;
  final String racketType;
  final int winCount;
  final int defeatCount;

  MySimpleInfo({
    required this.nickName,
    required this.profileImage,
    required this.racketType,
    required this.winCount,
    required this.defeatCount
  });

  factory MySimpleInfo.fromJson(Map<String, dynamic> json) {
    return MySimpleInfo(
      nickName: json['nickName'],
      profileImage: json['profileImage'],
      racketType: json['racketType'],
      winCount: json['winCount'],
      defeatCount: json['defeatCount']
    );
  }

  factory MySimpleInfo.empty() {
    return MySimpleInfo(
      nickName: '',
      profileImage: '',
      racketType: '',
      winCount: 0,
      defeatCount: 0
    );
  }
}