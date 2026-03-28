import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/gym_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcGymService {
  late GymNotifier notifier;
  final GymHttpService _httpService;
  AcGymService(this._httpService);

  Future<bool> createGym({required GymModel gym}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createGym(gym);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC GYM SERVICE CREATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateGym({required String id, required GymModel gym}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateGym(id, gym);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC GYM SERVICE UPDATE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteGym({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteGym(id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print('CAIU NO AC GYM SERVICE DELETE: $e');
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
