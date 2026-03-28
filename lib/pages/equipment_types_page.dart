import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/ac_equipment_type_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/in_equipment_type_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_equipment_type.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class EquipmentTypesPage extends StatefulWidget {
  const EquipmentTypesPage({super.key});

  @override
  State<EquipmentTypesPage> createState() => _EquipmentTypesPageState();
}

class _EquipmentTypesPageState extends State<EquipmentTypesPage> {
  final InEquipmentTypeService _inService = getIt<InEquipmentTypeService>();
  final AcEquipmentTypeService _acService = getIt<AcEquipmentTypeService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inService.getAllEquipmentTypes();
      _acService.notifier = _inService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Tipos de Equipamento',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Tipos de Equipamento'),
              ElevatedButton(
                onPressed: () async {
                  final saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogEquipmentType(
                      action: ActionEnum.insert,
                      acService: _acService,
                    ),
                  );
                  if (saved == true) await _inService.getAllEquipmentTypes();
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
                    is SuccessState<List<EquipmentTypeModel>>) {
                  final types = (_inService.notifier.state
                          as SuccessState<List<EquipmentTypeModel>>)
                      .data ?? [];
                  return GenericDataTable<EquipmentTypeModel>(
                    title: 'Tipos de Equipamento',
                    items: types,
                    isLoading: false,
                    onRefresh: () async => _inService.getAllEquipmentTypes(),
                    columns: const [
                      DataColumn(
                          label: Text('Nome',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Descrição',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Ações',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rowBuilder: (type) => DataRow(cells: [
                      DataCell(Text(type.name)),
                      DataCell(Text(type.description)),
                      DataCell(_actions(type)),
                    ]),
                  );
                } else if (_inService.notifier.state is FailedState) {
                  return const Center(
                      child: Text('Erro ao carregar tipos de equipamento'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(EquipmentTypeModel type) {
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
              builder: (_) => DialogEquipmentType(
                action: ActionEnum.edit,
                acService: _acService,
                equipmentType: type,
              ),
            );
            if (saved == true) await _inService.getAllEquipmentTypes();
          },
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Excluir o tipo "${type.name}"?',
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
              final deleted = await _acService.deleteEquipmentType(id: type.id);
              if (deleted) await _inService.getAllEquipmentTypes();
            }
          },
        ),
      ],
    );
  }
}
