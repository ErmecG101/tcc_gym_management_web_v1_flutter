class EquipmentTypeModel {
  final String id;
  final String name;
  final String description;

  const EquipmentTypeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory EquipmentTypeModel.empty() =>
      const EquipmentTypeModel(id: '', name: '', description: '');

  factory EquipmentTypeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return EquipmentTypeModel.empty();
    return EquipmentTypeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}
