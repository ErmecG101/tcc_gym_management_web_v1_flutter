import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/equipment_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InEquipmentService {
  final _notifier = EquipmentNotifier();
  final EquipmentHttpService _httpService;
  InEquipmentService(this._httpService);

  EquipmentNotifier get notifier => _notifier;

  Future<void> getAllEquipments() async {
    notifier.state = LoadingState();
    try {
      final equipments = await _httpService.getAllEquipments();
      notifier.state = SuccessState(data: equipments);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
