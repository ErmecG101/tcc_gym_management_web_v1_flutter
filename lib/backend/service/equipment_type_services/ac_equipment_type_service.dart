import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/equipment_type_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcEquipmentTypeService {
  late EquipmentTypeNotifier notifier;
  final EquipmentTypeHttpService _httpService;
  AcEquipmentTypeService(this._httpService);

  Future<bool> createEquipmentType({required EquipmentTypeModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createEquipmentType(model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT TYPE SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateEquipmentType({required EquipmentTypeModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateEquipmentType(model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT TYPE SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteEquipmentType({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteEquipmentType(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC EQUIPMENT TYPE SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
