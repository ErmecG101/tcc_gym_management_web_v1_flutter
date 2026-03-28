import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';

class MaintenanceHttpService {
  final Defaulthttpclient _httpClient;
  MaintenanceHttpService(this._httpClient);

  Future<List<MaintenanceModel>> getAllMaintenances() async {
    try {
      final response = await _httpClient.get('maintenances', null, {});
      if (response is List) {
        return response
            .map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
      throw Exception('Unexpected response type from GET maintenances');
    } catch (e) {
      print('CAIU NO MAINTENANCE HTTP SERVICE GET ALL: $e');
      rethrow;
    }
  }

  Future<MaintenanceModel> getMaintenanceById(String id) async {
    try {
      final response = await _httpClient.get('maintenances/$id', null, {});
      return MaintenanceModel.fromJson(response as Map<String, dynamic>?);
    } catch (e) {
      print('CAIU NO MAINTENANCE HTTP SERVICE GET BY ID: $e');
      rethrow;
    }
  }

  Future<bool> createMaintenance(MaintenanceModel model) async {
    try {
      final body = model.toJson()..remove('id');
      await _httpClient.post('maintenances', null, body);
      return true;
    } catch (e) {
      print('CAIU NO MAINTENANCE HTTP SERVICE CREATE: $e');
      rethrow;
    }
  }

  Future<bool> updateMaintenance(String id, MaintenanceModel model) async {
    try {
      return await _httpClient.put('maintenances/$id', null, model.toJson());
    } catch (e) {
      print('CAIU NO MAINTENANCE HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteMaintenance(String id) async {
    try {
      return await _httpClient.delete('maintenances/$id', null, {});
    } catch (e) {
      print('CAIU NO MAINTENANCE HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }
}
