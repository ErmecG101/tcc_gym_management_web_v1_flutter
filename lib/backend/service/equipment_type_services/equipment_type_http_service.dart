import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';

class EquipmentTypeHttpService {
  final Defaulthttpclient _httpClient;
  EquipmentTypeHttpService(this._httpClient);

  Future<List<EquipmentTypeModel>> getAllEquipmentTypes() async {
    try {
      final response = await _httpClient.get('equipment-types', null, {});
      if (response is List) {
        return response
            .map((e) => EquipmentTypeModel.fromJson(e as Map<String, dynamic>?))
            .toList();
      }
      throw Exception('Unexpected response type from GET equipment-types');
    } catch (e) {
      print('CAIU NO EQUIPMENT TYPE HTTP SERVICE GET ALL: $e');
      rethrow;
    }
  }

  Future<bool> createEquipmentType(EquipmentTypeModel model) async {
    try {
      final body = model.toJson()..remove('id');
      await _httpClient.post('equipment-types', null, body);
      return true;
    } catch (e) {
      print('CAIU NO EQUIPMENT TYPE HTTP SERVICE CREATE: $e');
      rethrow;
    }
  }

  // PUT /equipment-types uses body ID (no path variable)
  Future<bool> updateEquipmentType(EquipmentTypeModel model) async {
    try {
      return await _httpClient.put('equipment-types', null, model.toJson());
    } catch (e) {
      print('CAIU NO EQUIPMENT TYPE HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteEquipmentType(String id) async {
    try {
      return await _httpClient.delete('equipment-types/$id', null, {});
    } catch (e) {
      print('CAIU NO EQUIPMENT TYPE HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }
}
