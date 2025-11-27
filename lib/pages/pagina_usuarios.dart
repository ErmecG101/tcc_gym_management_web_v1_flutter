import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';

class PaginaUsuarios extends StatefulWidget {
  const PaginaUsuarios({super.key});

  @override
  State<PaginaUsuarios> createState() => _PaginaUsuariosState();
}

class _PaginaUsuariosState extends State<PaginaUsuarios> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Usuários",
      body: Column(children: [Text("Tela Usuarios")]),
    );
  }
}
