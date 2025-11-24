import 'package:tcc_gym_management_web_v1_flutter/backend/notifiers/login_notifier.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/login_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';

class AcLoginService {

  LoginNotifier notifier = LoginNotifier();
  final LoginHttpService _httpService;
  AcLoginService(this._httpService);

  Future<bool> logar({required Function(String mensagemErro) exibirErro})async{
    notifier.state = LoadingState(); 
    try{
      final result = await _httpService.executarLogin(username: notifier.tecUserName.text, password: notifier.tecPassword.text);
      notifier.state = SuccessState();
      return result;
    }catch (e, sttr){
      print(e);
      print(sttr);
      notifier.state = FailedState(e.toString());
      exibirErro(e.toString());
      return false;
    }
  }

}