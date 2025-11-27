import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/login_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/pagina_teste.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    isItLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Column(
        children: [
          Text("Hello World"),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaginaTeste()),
              );
            },
            child: Text("A"),
          ),
        ],
      ),
    );
  }

  Future<void> isItLoggedIn() async {
    final SharedPreferences prefsInt = await SharedPreferences.getInstance();
    if (!prefsInt.containsKey("user")) {
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      showDialog(
        context: context,
        builder: (context) => DialogAviso(
          aviso:
              "Login Inválido ou expirado, por favor realise o login novamente.",
        ),
      );
    }
  }
}
