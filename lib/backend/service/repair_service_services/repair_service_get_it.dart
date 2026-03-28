import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/ac_repair_service_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/in_repair_service_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class RepairServiceGetIt {
  RepairServiceGetIt._internal();
  static final instance = RepairServiceGetIt._internal();

  void register() {
    getIt.registerFactory<RepairServiceHttpService>(
      () => RepairServiceHttpService(getIt<Defaulthttpclient>()),
    );
    getIt.registerFactory<InRepairServiceService>(
      () => InRepairServiceService(getIt<RepairServiceHttpService>()),
    );
    getIt.registerFactory<AcRepairServiceService>(
      () => AcRepairServiceService(getIt<RepairServiceHttpService>()),
    );
  }
}
