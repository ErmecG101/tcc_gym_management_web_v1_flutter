import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';

class UserModel {
  final String id;
  final String name;
  final String userName;
  final String password;
  final String document;
  final String email;
  final String phoneNumber;
  final GymModel gymDto;

  const UserModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.password,
    required this.document,
    required this.email,
    required this.phoneNumber,
    required this.gymDto,
  });

  factory UserModel.empty() {
    return UserModel(
      id: "",
      name: "",
      userName: "",
      password: "",
      document: "",
      email: "",
      phoneNumber: "",
      gymDto: GymModel.empty(),
    );
  }

  UserModel copyWith(
    String? id,
    String? name,
    String? userName,
    String? password,
    String? document,
    String? email,
    String? phoneNumber,
    GymModel? gymDto,
  ) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      document: document ?? this.document,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gymDto: gymDto ?? this.gymDto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "userName": userName,
      "password": password,
      "document": document,
      "email": email,
      "phoneNumber": phoneNumber,
      "gymDto": gymDto.toJson(),
    };
  }

  UserModel fromJson(Map<String, dynamic> json) {
    return UserModel.empty().copyWith(
      json['id'],
      json['name'],
      json['userName'],
      json['password'],
      json['document'],
      json['email'],
      json['phoneNumber'],
      GymModel.empty().fromJson(json['gymDTO']),
    );
  }
}
