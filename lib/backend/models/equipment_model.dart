import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';

class EquipmentModel {
  final String id;
  final String name;
  final String description;
  final String propertyNumber;
  final String purchaseDate;
  final double originalValue;
  final double currentValue;
  final double depreciationPercentage;
  final double durability;
  final EquipmentTypeModel equipmentType;
  final GymModel gymDTO;

  const EquipmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.propertyNumber,
    required this.purchaseDate,
    required this.originalValue,
    required this.currentValue,
    required this.depreciationPercentage,
    required this.durability,
    required this.equipmentType,
    required this.gymDTO,
  });

  factory EquipmentModel.empty() => EquipmentModel(
        id: '',
        name: '',
        description: '',
        propertyNumber: '',
        purchaseDate: '',
        originalValue: 0,
        currentValue: 0,
        depreciationPercentage: 0,
        durability: 0,
        equipmentType: EquipmentTypeModel.empty(),
        gymDTO: GymModel.empty(),
      );

  factory EquipmentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EquipmentModel.empty();
    return EquipmentModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      propertyNumber: json['propertyNumber'] as String? ?? '',
      purchaseDate: json['purchaseDate'] as String? ?? '',
      originalValue: (json['originalValue'] as num?)?.toDouble() ?? 0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0,
      depreciationPercentage:
          (json['depreciationPercentage'] as num?)?.toDouble() ?? 0,
      durability: (json['durability'] as num?)?.toDouble() ?? 0,
      equipmentType: EquipmentTypeModel.fromJson(
        json['equipmentType'] as Map<String, dynamic>?,
      ),
      gymDTO: GymModel.fromJson(json['gymDTO'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'propertyNumber': propertyNumber,
        'purchaseDate': purchaseDate,
        'originalValue': originalValue,
        'currentValue': currentValue,
        'depreciationPercentage': depreciationPercentage,
        'durability': durability,
        'equipmentType': equipmentType.toJson(),
        'gymDTO': {
          'id': gymDTO.id,
          'name': gymDTO.name,
          'document': gymDTO.document,
          'phoneNumber': gymDTO.phoneNumber,
        },
      };
}
