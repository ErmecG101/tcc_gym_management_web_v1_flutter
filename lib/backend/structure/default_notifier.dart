import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class DefaultNotifier extends ChangeNotifier{

  IGenericoState _state = InitialState();

  IGenericoState get state => _state;

  set state(IGenericoState state){
    this._state = state;
    notifyListeners();
  }

}