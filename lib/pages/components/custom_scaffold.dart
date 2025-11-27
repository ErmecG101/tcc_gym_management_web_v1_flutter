import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/other_constants.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/default_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_drawer.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/login_page.dart';

class CustomScaffold extends StatefulWidget {
  const CustomScaffold({
    super.key,
    required this.body,
    this.padding = 8,
    this.title = OtherConstants.projectName,
  });
  final Widget body;
  final double padding;
  final String title;

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  late final UserModel user;
  DefaultNotifier _defaultNotifier = DefaultNotifier();
  double get _bodyPadding => widget.padding;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? jsonStr = pref.getString("user");
      _defaultNotifier.state = LoadingState();
      if (jsonStr != null) {
        user = UserModel.empty().fromJson(jsonDecode(jsonStr));
        _defaultNotifier.state = SuccessState();
      } else {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _defaultNotifier,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 8,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                label: _defaultNotifier.state is! SuccessState
                    ? CircularProgressIndicator()
                    : Text(user.name),
                icon: Icon(Icons.person),
              ),
            ),
          ],
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu),
              );
            },
          ),
        ),
        drawer: CustomDrawer(),
        body: Padding(
          padding: EdgeInsets.all(_bodyPadding),
          child: widget.body,
        ),
      ),
    );
  }
}
