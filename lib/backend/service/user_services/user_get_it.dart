import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/ac_user_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/in_user_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/user_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class UserGetIt {
  UserGetIt._internal();
  static final instance = UserGetIt._internal();

  void _executeInternal() {
    getIt.registerLazySingleton<UserHttpService>(
      () => UserHttpService(getIt<Defaulthttpclient>()),
    );

    getIt.registerFactory<InUserService>(
      () => InUserService(getIt<UserHttpService>()),
    );

    getIt.registerFactory<AcUserService>(
      () => AcUserService(getIt<UserHttpService>()),
    );
  }

  void register() {
    _executeInternal();
  }
}
