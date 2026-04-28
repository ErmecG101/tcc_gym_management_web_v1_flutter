import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/ac_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/in_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_maintenance.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class MaintenancesPage extends StatefulWidget {
  const MaintenancesPage({super.key});

  @override
  State<MaintenancesPage> createState() => _MaintenancesPageState();
}

class _MaintenancesPageState extends State<MaintenancesPage> {
  final InMaintenanceService _inService = getIt<InMaintenanceService>();
  final AcMaintenanceService _acService = getIt<AcMaintenanceService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inService.getAllMaintenances();
      _acService.notifier = _inService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Empresas de Manutenção',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Empresas de Manutenção'),
              ElevatedButton(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogMaintenance(
                      action: ActionEnum.insert,
                      acService: _acService,
                    ),
                  );
                  if (saved == true) await _inService.getAllMaintenances();
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
                } else if (_inService.notifier.state
                    is SuccessState<List<MaintenanceModel>>) {
                  final items = (_inService.notifier.state
                          as SuccessState<List<MaintenanceModel>>)
                      .data ?? [];
                  return GenericDataTable<MaintenanceModel>(
                    title: 'Empresas de Manutenção',
                    items: items,
                    isLoading: false,
                    onRefresh: () async => _inService.getAllMaintenances(),
                    columns: const [
                      DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Documento', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Telefone', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Contato', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Academia', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rowBuilder: (m) => DataRow(cells: [
                      DataCell(Text(m.name)),
                      DataCell(Text(m.document)),
                      DataCell(Text(m.phoneNumber)),
                      DataCell(Text(m.contactEmployee)),
                      DataCell(Text(m.gymDTO.name)),
                      DataCell(_actions(m)),
                    ]),
                  );
                } else if (_inService.notifier.state is FailedState) {
                  return const Center(
                      child: Text('Erro ao carregar empresas de manutenção'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(MaintenanceModel maintenance) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Visualizar',
          icon: const Icon(Icons.visibility),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => DialogMaintenance(
              action: ActionEnum.view,
              acService: _acService,
              maintenance: maintenance,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final saved = await showDialog<bool>(
              context: context,
              builder: (_) => DialogMaintenance(
                action: ActionEnum.edit,
                acService: _acService,
                maintenance: maintenance,
              ),
            );
            if (saved == true) await _inService.getAllMaintenances();
          },
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Excluir a empresa "${maintenance.name}"?',
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
              final deleted =
                  await _acService.deleteMaintenance(id: maintenance.id);
              if (deleted) await _inService.getAllMaintenances();
            }
          },
        ),
      ],
    );
  }
}
