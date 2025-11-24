import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/ac_login_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/text_form_field_custom.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/principal_page.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AcLoginService acLogin = getIt<AcLoginService>();

  final _loginFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: SizedBox(
        width: 0.3 * MediaQuery.of(context).size.width,
        height: 0.5 * MediaQuery.of(context).size.height,
        child: Card(
          child: AnimatedBuilder(
            animation: acLogin.notifier,
            builder: (context, child) {
              final state = acLogin.notifier.state;
              if(state is LoadingState){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                );
              }
              if(state is FailedState){
                
              }
              return Form(
                key: _loginFormKey,
                child: Padding(padding: EdgeInsetsGeometry.all(8), child: Column( mainAxisAlignment: MainAxisAlignment.spaceAround,spacing: 16,children: [
                Text("Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
                TextFormFieldCustom(controller: acLogin.notifier.tecUserName, hint: "JohnDoe", name: "Username", validator: (value) => validateStringEmpty(value),),
                TextFormFieldCustom(controller: acLogin.notifier.tecPassword, hint: "********", name: "Password", inputType: TextInputType.visiblePassword,),
                ElevatedButton(onPressed: () {
                  acLogin.logar(
                    exibirErro: (mensagemErro) => showError(mensagemErro),
                  ).then((result) {
                    if(result){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => PrincipalPage()));
                    }
                  });
                }, child: Text("Login"))
                            ],),),
              );
            },
          ),
        ),
      ),
    ),);
  }

  String? validateStringEmpty(String value){
    if(value.isEmpty){
      return "O campo não pode ser nulo.";
    }
    return null;
  }

  void showError(String errorMessage){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro login: $errorMessage")));
  }
}