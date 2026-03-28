import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/ac_request_service.dart';

class DialogRequest extends StatefulWidget {
  const DialogRequest({
    super.key,
    required this.action,
    required this.request,
    this.acRequestService,
  });

  final ActionEnum action;
  final MaintenanceRequestModel request;
  final AcRequestService? acRequestService;

  @override
  State<DialogRequest> createState() => _DialogRequestState();
}

class _DialogRequestState extends State<DialogRequest> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _observationController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.request.description,
    );
    _observationController = TextEditingController(
      text: widget.request.observation ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _saveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = MaintenanceRequestModel(
      id: widget.request.id,
      requestNumber: widget.request.requestNumber,
      description: _descriptionController.text.trim(),
      observation: _observationController.text.trim().isEmpty
          ? null
          : _observationController.text.trim(),
      createdAt: widget.request.createdAt,
      updatedAt: widget.request.updatedAt,
      closedAt: widget.request.closedAt,
      maintenanceDTO: widget.request.maintenanceDTO,
      userDTO: widget.request.userDTO,
      equipments: widget.request.equipments,
      maintenances: widget.request.maintenances,
      conditions: widget.request.conditions,
    );

    try {
      await widget.acRequestService!.updateRequest(
        id: updated.id,
        request: updated,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.action == ActionEnum.view;
    final title = isView ? 'Detalhes do Request' : 'Editar Request';

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _InfoRow(
                  label: 'Nº Request',
                  value: widget.request.requestNumber.toString(),
                ),
                _InfoRow(
                  label: 'Criado em',
                  value: widget.request.createdAt,
                ),
                if (widget.request.updatedAt != null)
                  _InfoRow(
                    label: 'Atualizado em',
                    value: widget.request.updatedAt!,
                  ),
                if (widget.request.closedAt != null)
                  _InfoRow(
                    label: 'Encerrado em',
                    value: widget.request.closedAt!,
                  ),
                const Divider(),
                if (isView) ...[
                  _InfoRow(
                    label: 'Descrição',
                    value: widget.request.description,
                  ),
                  _InfoRow(
                    label: 'Observação',
                    value: widget.request.observation ?? '-',
                  ),
                ] else ...[
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Descrição é obrigatória'
                        : null,
                  ),
                  TextFormField(
                    controller: _observationController,
                    decoration: const InputDecoration(labelText: 'Observação'),
                    maxLines: 2,
                  ),
                ],
                const Divider(),
                _InfoRow(
                  label: 'Manutenção',
                  value: widget.request.maintenanceDTO.name,
                ),
                _InfoRow(
                  label: 'Telefone',
                  value: widget.request.maintenanceDTO.phone,
                ),
                _InfoRow(
                  label: 'Solicitante',
                  value: widget.request.userDTO.name,
                ),
                _InfoRow(
                  label: 'Email',
                  value: widget.request.userDTO.email,
                ),
                if (widget.request.equipments.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Equipamentos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...widget.request.equipments.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('• ${e.name} (${e.propertyNumber})'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Fechar'),
        ),
        if (!isView)
          ElevatedButton(
            onPressed: _saveRequest,
            child: const Text('Atualizar'),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
