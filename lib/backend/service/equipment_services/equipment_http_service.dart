import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';

class EquipmentHttpService {
  final Defaulthttpclient _httpClient;
  EquipmentHttpService(this._httpClient);

  Future<List<EquipmentModel>> getAllEquipments() async {
    try {
      final response = await _httpClient.get('equipments', null, {});
      if (response is List) {
        return response
            .map((e) => EquipmentModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
      throw Exception('Unexpected response type from GET equipments');
    } catch (e) {
      print('CAIU NO EQUIPMENT HTTP SERVICE GET ALL: $e');
      rethrow;
    }
  }

  Future<EquipmentModel> getEquipmentById(String id) async {
    try {
      final response = await _httpClient.get('equipments/$id', null, {});
      return EquipmentModel.fromJson(response as Map<String, dynamic>?);
    } catch (e) {
      print('CAIU NO EQUIPMENT HTTP SERVICE GET BY ID: $e');
      rethrow;
    }
  }

  Future<bool> createEquipment(EquipmentModel model) async {
    try {
      final body = model.toJson()..remove('id');
      await _httpClient.post('equipments', null, body);
      return true;
    } catch (e) {
      print('CAIU NO EQUIPMENT HTTP SERVICE CREATE: $e');
      rethrow;
    }
  }

  Future<bool> updateEquipment(String id, EquipmentModel model) async {
    try {
      return await _httpClient.put('equipments/$id', null, model.toJson());
    } catch (e) {
      print('CAIU NO EQUIPMENT HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteEquipment(String id) async {
    try {
      return await _httpClient.delete('equipments/$id', null, {});
    } catch (e) {
      print('CAIU NO EQUIPMENT HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }
}
