import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';

class MaintenanceModel {
  final String id;
  final String name;
  final String document;
  final String phoneNumber;
  final String email;
  final String address;
  final String contactEmployee;
  final GymModel gymDTO;

  const MaintenanceModel({
    required this.id,
    required this.name,
    required this.document,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.contactEmployee,
    required this.gymDTO,
  });

  factory MaintenanceModel.empty() => MaintenanceModel(
        id: '',
        name: '',
        document: '',
        phoneNumber: '',
        email: '',
        address: '',
        contactEmployee: '',
        gymDTO: GymModel.empty(),
      );

  factory MaintenanceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MaintenanceModel.empty();
    return MaintenanceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      document: json['document'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contactEmployee: json['contactEmployee'] as String? ?? '',
      gymDTO: GymModel.fromJson(json['gymDTO'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'document': document,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'contactEmployee': contactEmployee,
        'gymDTO': {
          'id': gymDTO.id,
          'name': gymDTO.name,
          'document': gymDTO.document,
          'phoneNumber': gymDTO.phoneNumber,
        },
      };
}
