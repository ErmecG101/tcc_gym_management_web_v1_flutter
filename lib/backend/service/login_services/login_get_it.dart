import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/ac_login_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/login_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class LoginGetIt {

  LoginGetIt._internal();
  static final instance = LoginGetIt._internal();

  void _executeInternal(){
    getIt.registerLazySingleton<LoginHttpService>(
      () => LoginHttpService(getIt<Defaulthttpclient>())
    );

    getIt.registerFactory<AcLoginService>(() => AcLoginService(getIt<LoginHttpService>()));
  }

  void register(){
    _executeInternal();
  }

}