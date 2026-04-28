import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/ac_repair_service_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/in_repair_service_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_repair_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class RepairServicesPage extends StatefulWidget {
  const RepairServicesPage({super.key});

  @override
  State<RepairServicesPage> createState() => _RepairServicesPageState();
}

class _RepairServicesPageState extends State<RepairServicesPage> {
  final InRepairServiceService _inService = getIt<InRepairServiceService>();
  final AcRepairServiceService _acService = getIt<AcRepairServiceService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inService.getAllRepairServices();
      _acService.notifier = _inService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Serviços de Reparo',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Serviços de Reparo'),
              ElevatedButton(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogRepairService(
                      action: ActionEnum.insert,
                      acService: _acService,
                    ),
                  );
                  if (saved == true) await _inService.getAllRepairServices();
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
                    is SuccessState<List<RepairServiceModel>>) {
                  final items = (_inService.notifier.state
                          as SuccessState<List<RepairServiceModel>>)
                      .data ?? [];
                  return GenericDataTable<RepairServiceModel>(
                    title: 'Serviços de Reparo',
                    items: items,
                    isLoading: false,
                    onRefresh: () async => _inService.getAllRepairServices(),
                    columns: const [
                      DataColumn(label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Preço Final', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Manutenção', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Código do Pedido', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rowBuilder: (rs) => DataRow(cells: [
                      DataCell(Text(rs.description)),
                      DataCell(Text('R\$ ${rs.subTotal.toStringAsFixed(2)}')),
                      DataCell(Text('R\$ ${rs.finalPrice.toStringAsFixed(2)}')),
                      DataCell(Text(rs.maintenance.name)),
                      DataCell(Text(rs.maintenanceRequestDTO.requestNumber.toString())),
                      DataCell(_actions(rs)),
                    ]),
                  );
                } else if (_inService.notifier.state is FailedState) {
                  return const Center(
                      child: Text('Erro ao carregar serviços de reparo'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(RepairServiceModel rs) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Visualizar',
          icon: const Icon(Icons.visibility),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => DialogRepairService(
              action: ActionEnum.view,
              acService: _acService,
              repairService: rs,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final saved = await showDialog<bool>(
              context: context,
              builder: (_) => DialogRepairService(
                action: ActionEnum.edit,
                acService: _acService,
                repairService: rs,
              ),
            );
            if (saved == true) await _inService.getAllRepairServices();
          },
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Excluir o serviço "${rs.description}"?',
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
              final deleted = await _acService.deleteRepairService(id: rs.id);
              if (deleted) await _inService.getAllRepairServices();
            }
          },
        ),
      ],
    );
  }
}
