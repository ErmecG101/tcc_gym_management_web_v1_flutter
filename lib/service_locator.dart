import 'package:get_it/get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/login_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/default_http_client_get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator(){
  DefaultHttpClientGetIt.instance.register();
  LoginGetIt.instance.register();
}

