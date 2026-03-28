import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/ac_gym_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/in_gym_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_gym.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class GymsPage extends StatefulWidget {
  const GymsPage({super.key});

  @override
  State<GymsPage> createState() => _GymsPageState();
}

class _GymsPageState extends State<GymsPage> {
  final InGymService _inService = getIt<InGymService>();
  final AcGymService _acService = getIt<AcGymService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inService.getAllGyms();
      _acService.notifier = _inService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Academias',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Academias'),
              ElevatedButton(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogGym(
                      action: ActionEnum.insert,
                      acGymService: _acService,
                    ),
                  );
                  if (saved == true) await _inService.getAllGyms();
                },
                child: const Text('Adicionar'),
              ),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _inService.notifier,
              builder: (context, _) {
                if (_inService.notifier.state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_inService.notifier.state is SuccessState<List<GymModel>>) {
                  final gyms =
                      (_inService.notifier.state as SuccessState<List<GymModel>>).data ?? [];
                  return GenericDataTable<GymModel>(
                    title: 'Academias',
                    items: gyms,
                    isLoading: false,
                    onRefresh: () async => _inService.getAllGyms(),
                    columns: const [
                      DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('CNPJ', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Telefone', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rowBuilder: (gym) => DataRow(cells: [
                      DataCell(Text(gym.name)),
                      DataCell(Text(gym.document)),
                      DataCell(Text(gym.phoneNumber)),
                      DataCell(Text(gym.email)),
                      DataCell(_actions(gym)),
                    ]),
                  );
                } else if (_inService.notifier.state is FailedState) {
                  return const Center(child: Text('Erro ao carregar academias'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(GymModel gym) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final saved = await showDialog<bool>(
              context: context,
              builder: (_) => DialogGym(
                action: ActionEnum.edit,
                acGymService: _acService,
                gym: gym,
              ),
            );
            if (saved == true) await _inService.getAllGyms();
          },
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Tem certeza que deseja excluir a academia "${gym.name}"?',
                acoes: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sim'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Não'),
                  ),
                ],
              ),
            );
            if (shouldDelete == true) {
              final deleted = await _acService.deleteGym(id: gym.id);
              if (deleted) await _inService.getAllGyms();
            }
          },
        ),
      ],
    );
  }
}
