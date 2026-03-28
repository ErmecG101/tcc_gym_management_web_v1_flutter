import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';

class GymHttpService {
  final Defaulthttpclient _httpClient;
  GymHttpService(this._httpClient);

  Future<List<GymModel>> getAllGyms() async {
    try {
      final response = await _httpClient.get('gyms', null, {});
      if (response is List) {
        return response
            .map((e) => GymModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
      throw Exception('Unexpected response type from GET gyms');
    } catch (e) {
      print('CAIU NO GYM HTTP SERVICE GET ALL: $e');
      rethrow;
    }
  }

  Future<GymModel> getGymById(String id) async {
    try {
      final response = await _httpClient.get('gyms/$id', null, {});
      return GymModel.fromJson(response as Map<String, dynamic>?);
    } catch (e) {
      print('CAIU NO GYM HTTP SERVICE GET BY ID: $e');
      rethrow;
    }
  }

  Future<bool> createGym(GymModel gym) async {
    try {
      await _httpClient.post('gyms', null, gym.toJson());
      return true;
    } catch (e) {
      print('CAIU NO GYM HTTP SERVICE CREATE: $e');
      rethrow;
    }
  }

  Future<bool> updateGym(String id, GymModel gym) async {
    try {
      return await _httpClient.put('gyms/$id', null, gym.toJson());
    } catch (e) {
      print('CAIU NO GYM HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteGym(String id) async {
    try {
      return await _httpClient.delete('gyms/$id', null, {});
    } catch (e) {
      print('CAIU NO GYM HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }
}
