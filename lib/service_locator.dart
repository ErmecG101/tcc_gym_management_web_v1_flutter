import 'package:get_it/get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/login_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/user_get_it.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/default_http_client_get_it.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  DefaultHttpClientGetIt.instance.register();
  LoginGetIt.instance.register();
  UserGetIt.instance.register();
  RequestGetIt.instance.register();
  GymGetIt.instance.register();
  EquipmentTypeGetIt.instance.register();
  EquipmentGetIt.instance.register();
  MaintenanceGetIt.instance.register();
  RepairServiceGetIt.instance.register();
}
