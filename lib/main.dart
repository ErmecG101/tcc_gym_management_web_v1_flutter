import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/principal_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: PrincipalPage(),
    );
  }

}