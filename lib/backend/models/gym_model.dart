class GymModel {
  final String id;
  final String name;
  final String document;
  final String phoneNumber;
  final String email;
  final String address;

  const GymModel({required this.id, required this.name, required this.document, required this.phoneNumber, required this.email, required this.address});

  factory GymModel.empty(){
    return GymModel(id: "", name: "", document: "", phoneNumber: "", email: "", address: "");
  }

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "document" : document,
      "phoneNumber" : phoneNumber,
      "email" : email,
      "address" : address,
    };
  }

  GymModel copyWith(String? id, String? name, String? document, String? phoneNumber, String? email, String? address){
    return GymModel(id: id ?? this.id, name: name ?? this.name, address: address ?? this.address, document: document ?? this.document, email: email ?? this.email, phoneNumber: phoneNumber ?? this.phoneNumber,);
  }

  GymModel fromJson(Map<String, dynamic> json){
    return GymModel.empty().copyWith(json['id'], json['name'], json['address'], json['document'], json['email'], json['phoneNumber']);
  }
}