import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';

class UserHttpService {
  final Defaulthttpclient _defaulthttpclient;
  UserHttpService(this._defaulthttpclient);

  Future<List<UserModel>> getAllUsers() async {
    try {
      List<dynamic> usersJson = await _defaulthttpclient.get("users", null, {});
      print(usersJson);

      // filter out null entries and only convert maps
      return usersJson
          .where(
            (element) => element != null && element is Map<String, dynamic>,
          )
          .map(
            (userJson) => UserModel.fromJson(userJson as Map<String, dynamic>?),
          )
          .toList();
    } catch (e) {
      print("CAIU NO HTTP SERVICE: $e");
      rethrow;
    }
  }

  Future<bool> createUser({required UserModel user}) async {
    try {
      await _defaulthttpclient.post("users", null, user.toJson());
      return true;
    } on NoContentException {
      throw NoContentException('Usuário não criado: username já está em uso.');
    } catch (e) {
      print("CAIU NO CREATE USER HTTP SERVICE: $e");
      rethrow;
    }
  }

  Future<bool> updateUser({required String id, required UserModel user}) async {
    try {
      return await _defaulthttpclient.put("users/$id", null, user.toJson());
    } catch (e) {
      print("CAIU NO UPDATE USER HTTP SERVICE: $e");
      rethrow;
    }
  }

  Future<bool> deleteUser({required String id}) async {
    try {
      return await _defaulthttpclient.delete("users/$id", null, {});
    } catch (e) {
      print("CAIU NO DELETE USER HTTP SERVICE: $e");
      rethrow;
    }
  }
}
