import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/other_constants.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/equipment_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/equipment_types_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/gyms_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/login_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/maintenances_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/pagina_usuarios.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/principal_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/repair_services_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/requests_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/utils/page_utils.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              CupertinoIcons.globe,
              size: MediaQuery.of(context).size.width * .1,
            ),
            Text(
              OtherConstants.projectName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const PrincipalPage());
              },
              label: const Text('Home'),
              icon: const Icon(Icons.home),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const RequestsPage());
              },
              label: const Text('Requests'),
              icon: const Icon(Icons.build_circle),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const RepairServicesPage());
              },
              label: const Text('Serviços de Reparo'),
              icon: const Icon(Icons.handyman),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const EquipmentPage());
              },
              label: const Text('Equipamentos'),
              icon: const Icon(Icons.fitness_center),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const EquipmentTypesPage());
              },
              label: const Text('Tipos de Equipamento'),
              icon: const Icon(Icons.category),
            ),
            const Divider(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const MaintenancesPage());
              },
              label: const Text('Manutenções'),
              icon: const Icon(Icons.engineering),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const GymsPage());
              },
              label: const Text('Academias'),
              icon: const Icon(Icons.business),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, const PaginaUsuarios());
              },
              label: const Text('Usuários'),
              icon: const Icon(Icons.people),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => LoginPage()),
                );
              },
              label: const Text('Sair'),
              icon: const Icon(Icons.exit_to_app),
            ),
            Text(OtherConstants.version, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
