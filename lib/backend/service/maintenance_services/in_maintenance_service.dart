import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/maintenance_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InMaintenanceService {
  final _notifier = MaintenanceNotifier();
  final MaintenanceHttpService _httpService;
  InMaintenanceService(this._httpService);

  MaintenanceNotifier get notifier => _notifier;

  Future<void> getAllMaintenances() async {
    notifier.state = LoadingState();
    try {
      final maintenances = await _httpService.getAllMaintenances();
      notifier.state = SuccessState(data: maintenances);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
