import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/ac_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/in_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_equipment.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final InEquipmentService _inService = getIt<InEquipmentService>();
  final AcEquipmentService _acService = getIt<AcEquipmentService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inService.getAllEquipments();
      _acService.notifier = _inService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Equipamentos',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Equipamentos'),
              ElevatedButton(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogEquipment(
                      action: ActionEnum.insert,
                      acService: _acService,
                    ),
                  );
                  if (saved == true) await _inService.getAllEquipments();
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
                    is SuccessState<List<EquipmentModel>>) {
                  final items = (_inService.notifier.state
                          as SuccessState<List<EquipmentModel>>)
                      .data ?? [];
                  return GenericDataTable<EquipmentModel>(
                    title: 'Equipamentos',
                    items: items,
                    isLoading: false,
                    onRefresh: () async => _inService.getAllEquipments(),
                    columns: const [
                      DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Nº Patrimônio', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Valor Atual', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Depreciação', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rowBuilder: (e) => DataRow(cells: [
                      DataCell(Text(e.name)),
                      DataCell(Text(e.propertyNumber)),
                      DataCell(Text(e.equipmentType.name)),
                      DataCell(Text('R\$ ${e.currentValue.toStringAsFixed(2)}')),
                      DataCell(Text('${e.depreciationPercentage.toStringAsFixed(2)}% a.a.')),
                      DataCell(_actions(e)),
                    ]),
                  );
                } else if (_inService.notifier.state is FailedState) {
                  return const Center(child: Text('Erro ao carregar equipamentos'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(EquipmentModel equipment) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Visualizar',
          icon: const Icon(Icons.visibility),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => DialogEquipment(
              action: ActionEnum.view,
              acService: _acService,
              equipment: equipment,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Editar',
          icon: const Icon(Icons.edit),
          onPressed: () async {
            final saved = await showDialog<bool>(
              context: context,
              builder: (_) => DialogEquipment(
                action: ActionEnum.edit,
                acService: _acService,
                equipment: equipment,
              ),
            );
            if (saved == true) await _inService.getAllEquipments();
          },
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Excluir o equipamento "${equipment.name}"?',
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
              final deleted = await _acService.deleteEquipment(id: equipment.id);
              if (deleted) await _inService.getAllEquipments();
            }
          },
        ),
      ],
    );
  }
}
