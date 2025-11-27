import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';

class PaginaTeste extends StatefulWidget {
  const PaginaTeste({super.key});

  @override
  State<PaginaTeste> createState() => _PaginaTesteState();
}

class _PaginaTesteState extends State<PaginaTeste> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(body: Column(
      children: [
        Text("Pagina Teste")
      ],
    ));
  }
}