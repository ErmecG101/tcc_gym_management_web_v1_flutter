import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/user_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/user_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InUserService {
  final _notifier = UserNotifier();
  final UserHttpService _httpService;
  InUserService(this._httpService);
  UserNotifier get notifier => _notifier;

  Future<void> getAllUsers() async {
    notifier.state = LoadingState();
    try {
      List<UserModel> users = await _httpService.getAllUsers();
      notifier.state = SuccessState(data: users);
    } catch (e) {
      print("CAIU NO IN USER SERVICE: $e");
      rethrow;
    }
  }
}
