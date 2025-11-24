import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class DefaultHttpClientGetIt {
    DefaultHttpClientGetIt._internal();
  static final instance = DefaultHttpClientGetIt._internal();


    void _executeInternal(){
      getIt.registerLazySingleton<Defaulthttpclient>(() => Defaulthttpclient());
    }

      void register(){
    _executeInternal();
  }
}