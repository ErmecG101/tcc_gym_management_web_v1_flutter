import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/gym_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InGymService {
  final _notifier = GymNotifier();
  final GymHttpService _httpService;
  InGymService(this._httpService);

  GymNotifier get notifier => _notifier;

  Future<void> getAllGyms() async {
    notifier.state = LoadingState();
    try {
      final gyms = await _httpService.getAllGyms();
      notifier.state = SuccessState(data: gyms);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
