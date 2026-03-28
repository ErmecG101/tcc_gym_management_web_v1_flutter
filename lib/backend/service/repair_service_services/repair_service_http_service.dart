import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';

class RepairServiceHttpService {
  final Defaulthttpclient _httpClient;
  RepairServiceHttpService(this._httpClient);

  Future<List<RepairServiceModel>> getAllRepairServices() async {
    try {
      final response =
          await _httpClient.get('maintenance-repair-services', null, {});
      if (response is List) {
        return response
            .map((e) => RepairServiceModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
      throw Exception(
          'Unexpected response type from GET maintenance-repair-services');
    } catch (e) {
      print('CAIU NO REPAIR SERVICE HTTP SERVICE GET ALL: $e');
      rethrow;
    }
  }

  Future<RepairServiceModel> getRepairServiceById(String id) async {
    try {
      final response =
          await _httpClient.get('maintenance-repair-services/$id', null, {});
      return RepairServiceModel.fromJson(response as Map<String, dynamic>?);
    } catch (e) {
      print('CAIU NO REPAIR SERVICE HTTP SERVICE GET BY ID: $e');
      rethrow;
    }
  }

  Future<bool> createRepairService(RepairServiceModel model) async {
    try {
      await _httpClient.post(
          'maintenance-repair-services', null, model.toJson());
      return true;
    } catch (e) {
      print('CAIU NO REPAIR SERVICE HTTP SERVICE CREATE: $e');
      rethrow;
    }
  }

  Future<bool> updateRepairService(String id, RepairServiceModel model) async {
    try {
      return await _httpClient.put(
          'maintenance-repair-services/$id', null, model.toJson());
    } catch (e) {
      print('CAIU NO REPAIR SERVICE HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteRepairService(String id) async {
    try {
      return await _httpClient.delete(
          'maintenance-repair-services/$id', null, {});
    } catch (e) {
      print('CAIU NO REPAIR SERVICE HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }
}
