import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/ac_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/in_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class MaintenanceGetIt {
  MaintenanceGetIt._internal();
  static final instance = MaintenanceGetIt._internal();

  void register() {
    getIt.registerFactory<MaintenanceHttpService>(
      () => MaintenanceHttpService(getIt<Defaulthttpclient>()),
    );
    getIt.registerFactory<InMaintenanceService>(
      () => InMaintenanceService(getIt<MaintenanceHttpService>()),
    );
    getIt.registerFactory<AcMaintenanceService>(
      () => AcMaintenanceService(getIt<MaintenanceHttpService>()),
    );
  }
}
