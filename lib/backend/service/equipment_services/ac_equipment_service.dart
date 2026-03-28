import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/equipment_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcEquipmentService {
  late EquipmentNotifier notifier;
  final EquipmentHttpService _httpService;
  AcEquipmentService(this._httpService);

  Future<bool> createEquipment({required EquipmentModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createEquipment(model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateEquipment({required String id, required EquipmentModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateEquipment(id, model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteEquipment({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteEquipment(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
