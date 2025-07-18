import 'package:image_picker/image_picker.dart';

class ProfileRegistrationDTO {
  final XFile? profileImage;
  final String nickName;

  ProfileRegistrationDTO({
    required this.profileImage,
    required this.nickName
  });

  ProfileRegistrationDTO copyWith({
    XFile? profileImage,
    String? nickName

  }) {
    return ProfileRegistrationDTO(
      profileImage: profileImage ?? this.profileImage,
      nickName: nickName ?? this.nickName
    );
  }
}