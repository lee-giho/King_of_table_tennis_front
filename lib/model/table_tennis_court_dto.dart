import 'package:king_of_table_tennis/model/location_dto.dart';

class TableTennisCourtDTO {
  final String id;
  final String name;
  final String address;
  final Location location;
  final String phoneNumber;
  final Map<String, String> businessHours;

  TableTennisCourtDTO({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.phoneNumber,
    required this.businessHours
  });

  // JSON -> 객체 변환
  factory TableTennisCourtDTO.fromJson(Map<String, dynamic> json) {
    return TableTennisCourtDTO(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      location: Location.fromJson(json['location']),
      phoneNumber: json['phoneNumber'],
      businessHours: Map<String, String>.from(json['businessHours'])
    );
  }
}