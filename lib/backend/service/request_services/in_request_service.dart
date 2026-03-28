import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/request_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class InRequestService {
  final _notifier = RequestNotifier();
  final RequestHttpService _httpService;
  InRequestService(this._httpService);

  RequestNotifier get notifier => _notifier;

  Future<void> getAllRequests() async {
    notifier.state = LoadingState();
    try {
      final requests = await _httpService.getAllMaintenanceRequests();
      notifier.state = SuccessState(data: requests);
    } catch (e) {
      notifier.state = FailedState(e.toString());
      rethrow;
    }
  }
}
