import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';

class MaintenanceRequestModel {
  final String id;
  final int requestNumber;
  final String description;
  final String? observation;
  final String createdAt;
  final String? updatedAt;
  final String? closedAt;
  final MaintenanceDTO maintenanceDTO;
  final UserDTO userDTO;
  final List<EquipmentModel> equipments;
  final List<MaintenanceDTO> maintenances;
  final List<String> conditions;

  MaintenanceRequestModel({
    required this.id,
    required this.requestNumber,
    required this.description,
    this.observation,
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
    required this.maintenanceDTO,
    required this.userDTO,
    required this.equipments,
    required this.maintenances,
    required this.conditions,
  });

  Map<String, dynamic> toJson() => {
        'requestNumber': requestNumber,
        'description': description,
        'observation': observation,
        'createdAt': createdAt,
        'maintenanceDTO': {
          'id': maintenanceDTO.id,
          'name': maintenanceDTO.name,
          'phone': maintenanceDTO.phone,
          'document': maintenanceDTO.document,
        },
        'userDTO': {
          'id': userDTO.id,
          'name': userDTO.name,
          'email': userDTO.email,
          'document': userDTO.document,
        },
        'equipments': equipments.map((e) => e.toJson()).toList(),
        'maintenances': maintenances
            .map((m) => {
                  'id': m.id,
                  'name': m.name,
                  'phone': m.phone,
                  'document': m.document,
                })
            .toList(),
        'services': [],
        'conditions': conditions,
      };

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('JSON is null');
    }

    return MaintenanceRequestModel(
      id: json['id'] as String? ?? '',
      requestNumber: (json['requestNumber'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      observation: json['observation'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      closedAt: json['closedAt'] as String?,
      maintenanceDTO: MaintenanceDTO.fromJson(
        json['maintenanceDTO'] as Map<String, dynamic>?,
      ),
      userDTO: UserDTO.fromJson(json['userDTO'] as Map<String, dynamic>?),
      equipments: (json['equipments'] as List<dynamic>?)
              ?.map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      maintenances: (json['maintenances'] as List<dynamic>?)
              ?.map((e) => MaintenanceDTO.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class MaintenanceDTO {
  final String id;
  final String name;
  final String phone;
  final String document;

  MaintenanceDTO({
    required this.id,
    required this.name,
    required this.phone,
    required this.document,
  });

  factory MaintenanceDTO.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MaintenanceDTO(id: '', name: '', phone: '', document: '');
    }
    return MaintenanceDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      document: json['document'] as String? ?? '',
    );
  }
}

class UserDTO {
  final String id;
  final String name;
  final String email;
  final String document;

  UserDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.document,
  });

  factory UserDTO.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserDTO(id: '', name: '', email: '', document: '');
    }
    return UserDTO(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      document: json['document'] as String? ?? '',
    );
  }
}
