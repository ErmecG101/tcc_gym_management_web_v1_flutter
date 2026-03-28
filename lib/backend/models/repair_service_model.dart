import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';

class RequestDTO {
  final String id;
  final int requestNumber;
  final String createdAt;

  const RequestDTO({
    required this.id,
    required this.requestNumber,
    required this.createdAt,
  });

  factory RequestDTO.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RequestDTO(id: '', requestNumber: 0, createdAt: '');
    return RequestDTO(
      id: json['id'] as String? ?? '',
      requestNumber: (json['requestNumber'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

class RepairServiceModel {
  final String id;
  final String description;
  final double subTotal;
  final double finalPrice;
  final MaintenanceModel maintenance;
  final RequestDTO maintenanceRequestDTO;
  final List<EquipmentModel> equipmentList;

  const RepairServiceModel({
    required this.id,
    required this.description,
    required this.subTotal,
    required this.finalPrice,
    required this.maintenance,
    required this.maintenanceRequestDTO,
    required this.equipmentList,
  });

  factory RepairServiceModel.empty() => RepairServiceModel(
        id: '',
        description: '',
        subTotal: 0,
        finalPrice: 0,
        maintenance: MaintenanceModel.empty(),
        maintenanceRequestDTO: const RequestDTO(id: '', requestNumber: 0, createdAt: ''),
        equipmentList: const [],
      );

  factory RepairServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RepairServiceModel.empty();
    return RepairServiceModel(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0,
      maintenance: MaintenanceModel.fromJson(
        json['maintenance'] as Map<String, dynamic>?,
      ),
      maintenanceRequestDTO: RequestDTO.fromJson(
        json['maintenanceRequestDTO'] as Map<String, dynamic>?,
      ),
      equipmentList: (json['equipmentList'] as List<dynamic>?)
              ?.map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'subTotal': subTotal,
        'finalPrice': finalPrice,
        'maintenance': maintenance.toJson(),
        'maintenanceRequestDTO': {
          'id': maintenanceRequestDTO.id,
          'requestNumber': maintenanceRequestDTO.requestNumber,
          'createdAt': maintenanceRequestDTO.createdAt,
        },
        'equipmentList': equipmentList.map((e) => e.toJson()).toList(),
      };
}
