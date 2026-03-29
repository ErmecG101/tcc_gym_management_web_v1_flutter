import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';

class RequestHttpService {
  final Defaulthttpclient _httpClient;
  RequestHttpService(this._httpClient);

  Future<MaintenanceRequestModel> getMaintenanceRequestById(String id) async {
    try {
      final response = await _httpClient.get('requests/$id', null, {});
      return MaintenanceRequestModel.fromJson(
        response as Map<String, dynamic>?,
      );
    } catch (e) {
      print('CAIU NO REQUEST HTTP SERVICE GET BY ID: $e');
      rethrow;
    }
  }

  Future<bool> updateMaintenanceRequest(
    String id,
    MaintenanceRequestModel request,
  ) async {
    try {
      return await _httpClient.put('requests/$id', null, request.toJson());
    } catch (e) {
      print('CAIU NO REQUEST HTTP SERVICE UPDATE: $e');
      rethrow;
    }
  }

  Future<bool> deleteMaintenanceRequest(String id) async {
    try {
      return await _httpClient.delete('requests/$id', null, {});
    } catch (e) {
      print('CAIU NO REQUEST HTTP SERVICE DELETE: $e');
      rethrow;
    }
  }

  Future<List<MaintenanceRequestModel>> getAllMaintenanceRequests() async {
    try {
      final response = await _httpClient.get('requests', null, {});
      if (response is List) {
        return response
            .map(
              (entry) => MaintenanceRequestModel.fromJson(
                entry as Map<String, dynamic>?,
              ),
            )
            .toList();
      }
      throw Exception('Unexpected response type from GET requests');
    } catch (e) {
      print('CAIU NO REQUEST HTTP SERVICE: $e');
      rethrow;
    }
  }
}
