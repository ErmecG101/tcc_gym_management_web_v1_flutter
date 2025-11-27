import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/login_services/ac_login_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/text_form_field_custom.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
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
    final width = 0.2 * MediaQuery.of(context).size.width;
    final height = 0.6 * MediaQuery.of(context).size.height;
    Color backgroundColor = Colors.deepOrange[200]!;
    Brightness brightness = ThemeData.estimateBrightnessForColor(
      backgroundColor,
    );
    Color textColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      body: Row(
        spacing: 8,
        children: [
          Flexible(
            flex: 2,
            child: Container(
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    "GymStock",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Bem vindo",
                    style: TextStyle(fontSize: 18, color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: SizedBox(
                width: width,
                height: height,
                child: Card(
                  child: AnimatedBuilder(
                    animation: acLogin.notifier,
                    builder: (context, child) {
                      final state = acLogin.notifier.state;
                      if (state is LoadingState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()],
                        );
                      }
                      return Form(
                        key: _loginFormKey,
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Icon(Icons.person, size: width * .25),

                              Column(
                                spacing: 8,
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormFieldCustom(
                                    controller: acLogin.notifier.tecUserName,
                                    hint: "JohnDoe",
                                    name: "Username",
                                  ),
                                  TextFormFieldCustom(
                                    controller: acLogin.notifier.tecPassword,
                                    hint: "********",
                                    name: "Password",
                                    inputType: TextInputType.visiblePassword,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => DialogAviso(
                                          aviso:
                                              "Se você não possui uma conta você deve requisitar uma para o administrador do sistema.",
                                        ),
                                      );
                                    },
                                    child: Text("Não possuo conta"),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_loginFormKey.currentState!.validate()) {
                                    acLogin
                                        .logar(
                                          exibirErro: (mensagemErro) =>
                                              showError(mensagemErro),
                                        )
                                        .then((result) {
                                          if (result) {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (builder) =>
                                                    PrincipalPage(),
                                              ),
                                            );
                                          }
                                        });
                                  }
                                },
                                child: Text("Login"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showError(String errorMessage) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Erro login: $errorMessage")));
  }
}
