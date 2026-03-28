import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/ac_gym_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/in_gym_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class GymGetIt {
  GymGetIt._internal();
  static final instance = GymGetIt._internal();

  void register() {
    getIt.registerFactory<GymHttpService>(
      () => GymHttpService(getIt<Defaulthttpclient>()),
    );
    getIt.registerFactory<InGymService>(
      () => InGymService(getIt<GymHttpService>()),
    );
    getIt.registerFactory<AcGymService>(
      () => AcGymService(getIt<GymHttpService>()),
    );
  }
}
