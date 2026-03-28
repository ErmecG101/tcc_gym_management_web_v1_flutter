import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/other_constants.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/login_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/pagina_usuarios.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/principal_page.dart';
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, PrincipalPage());
              },
              label: Text("Home"),
              icon: Icon(Icons.home),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, RequestsPage());
              },
              child: Text("Requests"),
            ),
            ElevatedButton(onPressed: () {}, child: Text("Opção 3")),
            ElevatedButton(onPressed: () {}, child: Text("Opção 4")),
            ElevatedButton(onPressed: () {}, child: Text("Opção 5")),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PageUtils.navigateTo(context, PaginaUsuarios());
              },
              label: Text("Usuarios"),
              icon: Icon(Icons.people),
            ),
            SizedBox(height: 32),
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
              label: Text("Sair"),
              icon: Icon(Icons.exit_to_app),
            ),
            Text(OtherConstants.version, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
