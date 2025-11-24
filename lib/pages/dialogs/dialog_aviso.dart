import 'package:flutter/material.dart';

class DialogAviso extends StatelessWidget {
  const DialogAviso({super.key,
  this.titulo = "Alerta!",
  required this.aviso,
  this.acoes = const [],
  this.height = 0.10,
  this.width = 0.20
  });

  final String titulo;
  final String aviso;
  final List<Widget> acoes;
  final width;
  final height;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: acoes.isEmpty ? [
        ElevatedButton(
onPressed: () {
  Navigator.pop(context);
}, child: Text("Ok")
        )
      ] : acoes,
      title: Text(titulo),
      content: SizedBox(
        height: height * MediaQuery.of(context).size.height,
        width: width * MediaQuery.of(context).size.width,
        child: Column(
          spacing: 8,
          children: [
            Padding(padding: EdgeInsetsGeometry.all(8),
            child: Column(
              children: [
                Text(aviso),
              ],
            ),),
          ],
        ),
      ),
    );
  }
}