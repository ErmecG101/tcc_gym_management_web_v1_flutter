import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/ac_user_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/in_user_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_user.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class PaginaUsuarios extends StatefulWidget {
  const PaginaUsuarios({super.key});

  @override
  State<PaginaUsuarios> createState() => _PaginaUsuariosState();
}

class _PaginaUsuariosState extends State<PaginaUsuarios> {
  // sample data for display; in real app this would come from a service/notifier
  final InUserService _userService = getIt<InUserService>();
  final AcUserService _acUserService = getIt<AcUserService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userService.getAllUsers();
      _acUserService.notifier = _userService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: "Usuários",
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Lista de Usuário"),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final saved = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => DialogUser(
                          action: ActionEnum.insert,
                          acUserService: _acUserService,
                        ),
                      );
                      if (saved == true) {
                        await _userService.getAllUsers();
                      }
                    },
                    child: const Text("Adicionar"),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _userService.notifier,
              builder: (context, _) {
                if (_userService.notifier.state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_userService.notifier.state
                    is SuccessState<List<UserModel>>) {
                  final users =
                      (_userService.notifier.state
                              as SuccessState<List<UserModel>>)
                          .data;
                  return UserTable(
                    items: users ?? [],
                    isLoading: false,
                    onRefresh: () async {
                      await _userService.getAllUsers();
                    },
                    onEdit: (user) async {
                      final saved = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => DialogUser(
                          action: ActionEnum.edit,
                          acUserService: _acUserService,
                          user: user,
                        ),
                      );
                      if (saved == true) {
                        await _userService.getAllUsers();
                      }
                    },
                    onDelete: (user) async {
                      final prefs = await SharedPreferences.getInstance();
                      final userJson = prefs.getString("user");
                      final profileId = userJson != null
                          ? UserModel.fromJson(jsonDecode(userJson)).id
                          : null;
                      if (user.id == profileId) {
                        await showDialog(
                          context: context,
                          builder: (ctx) => DialogAviso(
                            aviso:
                                "Você não pode excluir o usuário atualmente logado.",
                            acoes: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => DialogAviso(
                          aviso:
                              "Tem certeza que deseja excluir o usuário ${user.name}?",
                          acoes: [
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(ctx, true);
                              },
                              child: const Text("Sim"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx, false);
                              },
                              child: const Text("Não"),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true) {
                        final deleted = await _acUserService.deleteUser(
                          id: user.id,
                        );
                        if (deleted) {
                          await _userService.getAllUsers();
                        }
                      }
                    },
                  );
                } else if (_userService.notifier.state is FailedState) {
                  return const Center(child: Text("Erro ao carregar usuários"));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
