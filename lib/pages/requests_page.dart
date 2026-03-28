import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/structure/state_generics.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/in_request_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/user_table.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final InRequestService _requestService = getIt<InRequestService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestService.getAllRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Requests',
      body: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Lista de Requests')],
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
                    title: 'Requests',
                    items: requests ?? [],
                    isLoading: false,
                    onRefresh: () async {
                      await _requestService.getAllRequests();
                    },
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Nº Request',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Descrição',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Manutenção',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Usuário',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Criado em',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rowBuilder: (request) {
                      return DataRow(
                        cells: [
                          DataCell(Text(request.requestNumber.toString())),
                          DataCell(Text(request.description)),
                          DataCell(Text(request.maintenanceDTO.name)),
                          DataCell(Text(request.userDTO.name)),
                          DataCell(Text(request.createdAt)),
                        ],
                      );
                    },
                  );
                } else if (_requestService.notifier.state is FailedState) {
                  return const Center(child: Text('Erro ao carregar requests'));
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
