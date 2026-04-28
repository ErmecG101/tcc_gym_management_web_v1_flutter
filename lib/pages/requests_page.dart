import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/ac_request_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/in_request_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_aviso.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/dialogs/dialog_request.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final InRequestService _requestService = getIt<InRequestService>();
  final AcRequestService _acRequestService = getIt<AcRequestService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestService.getAllRequests();
      _acRequestService.notifier = _requestService.notifier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Pedidos de Manutenção',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lista de Pedidos de Manutenção'),
              ElevatedButton(
                onPressed: () async {
                  final created = await showDialog<bool>(
                    context: context,
                    builder: (_) => DialogRequest(
                      action: ActionEnum.insert,
                      acRequestService: _acRequestService,
                    ),
                  );
                  if (created == true) await _requestService.getAllRequests();
                },
                child: const Text('Novo Pedido'),
              ),
            ],
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _requestService.notifier,
              builder: (context, _) {
                if (_requestService.notifier.state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else if (_requestService.notifier.state
                    is SuccessState<List<MaintenanceRequestModel>>) {
                  final requests =
                      (_requestService.notifier.state
                              as SuccessState<List<MaintenanceRequestModel>>)
                          .data;
                  return GenericDataTable<MaintenanceRequestModel>(
                    title: 'Pedidos',
                    items: requests ?? [],
                    isLoading: false,
                    onRefresh: () async => _requestService.getAllRequests(),
                    columns: const [
                      DataColumn(
                        label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Descrição', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Manutenção', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Solicitante', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Criado em', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                    rowBuilder: (request) => DataRow(
                      cells: [
                        DataCell(Text(request.requestNumber.toString())),
                        DataCell(Text(request.description)),
                        DataCell(Text(request.maintenanceDTO.name)),
                        DataCell(Text(request.userDTO.name)),
                        DataCell(Text(request.createdAt)),
                        DataCell(_actions(request)),
                      ],
                    ),
                  );
                } else if (_requestService.notifier.state is FailedState) {
                  return const Center(child: Text('Erro ao carregar pedidos'));
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

  Widget _actions(MaintenanceRequestModel request) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'Visualizar',
          icon: const Icon(Icons.visibility),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => DialogRequest(
              action: ActionEnum.view,
              request: request,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Excluir',
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (_) => DialogAviso(
                aviso: 'Tem certeza que deseja excluir o pedido Código ${request.requestNumber}?',
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
                  await _acRequestService.deleteRequest(id: request.id);
              if (deleted) await _requestService.getAllRequests();
            }
          },
        ),
      ],
    );
  }
}
