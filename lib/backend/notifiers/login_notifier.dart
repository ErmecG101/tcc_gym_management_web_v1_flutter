import 'package:flutter/widgets.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/default_notifier.dart';

class LoginNotifier extends DefaultNotifier{

  final TextEditingController tecUserName = TextEditingController();
  final TextEditingController tecPassword = TextEditingController();
  bool _passwordVisible = false;

  bool get passwordVisible => _passwordVisible;

  set passwordVisible(bool passwordVisible){
    this._passwordVisible = passwordVisible;
    notifyListeners();
  }

}