import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/repair_service_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InRepairServiceService {
  final _notifier = RepairServiceNotifier();
  final RepairServiceHttpService _httpService;
  InRepairServiceService(this._httpService);

  RepairServiceNotifier get notifier => _notifier;

  Future<void> getAllRepairServices() async {
    notifier.state = LoadingState();
    try {
      final services = await _httpService.getAllRepairServices();
      notifier.state = SuccessState(data: services);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
