import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';

class RequestHttpService {
  final Defaulthttpclient _httpClient;
  RequestHttpService(this._httpClient);

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
