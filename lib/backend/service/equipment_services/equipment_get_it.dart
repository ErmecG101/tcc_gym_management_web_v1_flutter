import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/ac_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/in_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class EquipmentGetIt {
  EquipmentGetIt._internal();
  static final instance = EquipmentGetIt._internal();

  void register() {
    getIt.registerFactory<EquipmentHttpService>(
      () => EquipmentHttpService(getIt<Defaulthttpclient>()),
    );
    getIt.registerFactory<InEquipmentService>(
      () => InEquipmentService(getIt<EquipmentHttpService>()),
    );
    getIt.registerFactory<AcEquipmentService>(
      () => AcEquipmentService(getIt<EquipmentHttpService>()),
    );
  }
}
