import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/request_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcRequestService {
  late RequestNotifier notifier;

  final RequestHttpService _httpService;
  AcRequestService(this._httpService);

  Future<bool> createRequest({required MaintenanceRequestModel request}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createMaintenanceRequest(request);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REQUEST SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateRequest({
    required String id,
    required MaintenanceRequestModel request,
  }) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateMaintenanceRequest(id, request);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REQUEST SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteRequest({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteMaintenanceRequest(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REQUEST SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
