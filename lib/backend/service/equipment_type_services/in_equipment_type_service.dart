import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/equipment_type_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InEquipmentTypeService {
  final _notifier = EquipmentTypeNotifier();
  final EquipmentTypeHttpService _httpService;
  InEquipmentTypeService(this._httpService);

  EquipmentTypeNotifier get notifier => _notifier;

  Future<void> getAllEquipmentTypes() async {
    notifier.state = LoadingState();
    try {
      final types = await _httpService.getAllEquipmentTypes();
      notifier.state = SuccessState(data: types);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
