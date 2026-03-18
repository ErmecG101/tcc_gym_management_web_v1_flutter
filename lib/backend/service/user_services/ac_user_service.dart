import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/user_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/user_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcUserService {
  late final UserNotifier notifier;

  AcUserService(this._httpService) {}

  final UserHttpService _httpService;

  Future<bool> createUser({required UserModel user}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.createUser(user: user);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print("CAIU NO AC USER SERVICE CREATE: $e");
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> updateUser({required String id, required UserModel user}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.updateUser(id: id, user: user);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print("CAIU NO AC USER SERVICE UPDATE: $e");
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }

  Future<bool> deleteUser({required String id}) async {
    notifier.state = LoadingState();
    try {
      final result = await _httpService.deleteUser(id: id);
      notifier.state = SuccessState();
      return result;
    } catch (e) {
      print("CAIU NO AC USER SERVICE: $e");
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
