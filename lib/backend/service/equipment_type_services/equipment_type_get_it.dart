import 'package:tcc_gym_management_web_v1_flutter/backend/http/DefaultHttpClient.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/ac_equipment_type_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/in_equipment_type_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class EquipmentTypeGetIt {
  EquipmentTypeGetIt._internal();
  static final instance = EquipmentTypeGetIt._internal();

  void register() {
    getIt.registerFactory<EquipmentTypeHttpService>(
      () => EquipmentTypeHttpService(getIt<Defaulthttpclient>()),
    );
    getIt.registerFactory<InEquipmentTypeService>(
      () => InEquipmentTypeService(getIt<EquipmentTypeHttpService>()),
    );
    getIt.registerFactory<AcEquipmentTypeService>(
      () => AcEquipmentTypeService(getIt<EquipmentTypeHttpService>()),
    );
  }
}
