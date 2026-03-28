import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/repair_service_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcRepairServiceService {
  late RepairServiceNotifier notifier;
  final RepairServiceHttpService _httpService;
  AcRepairServiceService(this._httpService);

  Future<bool> createRepairService({required RepairServiceModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createRepairService(model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REPAIR SERVICE SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateRepairService({required String id, required RepairServiceModel model}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateRepairService(id, model);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REPAIR SERVICE SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteRepairService({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteRepairService(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC REPAIR SERVICE SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
