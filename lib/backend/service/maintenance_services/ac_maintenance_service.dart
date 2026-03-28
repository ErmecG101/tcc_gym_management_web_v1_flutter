import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/maintenance_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcMaintenanceService {
  late MaintenanceNotifier notifier;
  final MaintenanceHttpService _httpService;
  AcMaintenanceService(this._httpService);

  Future<bool> createMaintenance({required MaintenanceModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createMaintenance(model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC MAINTENANCE SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateMaintenance({required String id, required MaintenanceModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateMaintenance(id, model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC MAINTENANCE SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteMaintenance({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteMaintenance(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC MAINTENANCE SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
