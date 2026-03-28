import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/in_request_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class RequestGetIt {
  RequestGetIt._internal();
  static final instance = RequestGetIt._internal();

  void _executeInternal() {
    getIt.registerFactory<RequestHttpService>(
      () => RequestHttpService(getIt<Defaulthttpclient>()),
    );

    getIt.registerFactory<InRequestService>(
      () => InRequestService(getIt<RequestHttpService>()),
    );
  }

  void register() {
    _executeInternal();
  }
}
