class GymModel {
  final String id;
  final String name;
  final String document;
  final String phoneNumber;
  final String email;
  final String address;

  const GymModel({
    required this.id,
    required this.name,
    required this.document,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  factory GymModel.empty() {
    return GymModel(
      id: "",
      name: "",
      document: "",
      phoneNumber: "",
      email: "",
      address: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "document": document,
      "phoneNumber": phoneNumber,
      "email": email,
      "address": address,
    };
  }

  GymModel copyWith(
    String? id,
    String? name,
    String? document,
    String? phoneNumber,
    String? email,
    String? address,
  ) {
    return GymModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      document: document ?? this.document,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// Creates a [GymModel] from a JSON map. If [json] is null or missing
  /// fields they default to empty strings.
  factory GymModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GymModel.empty();
    return GymModel.empty().copyWith(
      json['id'] as String?,
      json['name'] as String?,
      json['address'] as String?,
      json['document'] as String?,
      json['email'] as String?,
      json['phoneNumber'] as String?,
    );
  }
}
