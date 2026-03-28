import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/ac_repair_service_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class DialogRepairService extends StatefulWidget {
  const DialogRepairService({
    super.key,
    required this.action,
    required this.acService,
    this.repairService,
  });

  final ActionEnum action;
  final AcRepairServiceService acService;
  final RepairServiceModel? repairService;

  @override
  State<DialogRepairService> createState() => _DialogRepairServiceState();
}

class _DialogRepairServiceState extends State<DialogRepairService> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _subTotalController;
  late final TextEditingController _finalPriceController;

  List<MaintenanceModel> _maintenances = [];
  List<MaintenanceRequestModel> _requests = [];
  List<EquipmentModel> _equipments = [];
  MaintenanceModel? _selectedMaintenance;
  MaintenanceRequestModel? _selectedRequest;
  List<EquipmentModel> _selectedEquipments = [];
  bool _loadingOptions = true;

  @override
  void initState() {
    super.initState();
    final rs = widget.repairService;
    _descriptionController = TextEditingController(text: rs?.description ?? '');
    _subTotalController = TextEditingController(
      text: rs != null ? rs.subTotal.toString() : '',
    );
    _finalPriceController = TextEditingController(
      text: rs != null ? rs.finalPrice.toString() : '',
    );
    if (rs != null) _selectedEquipments = List.from(rs.equipmentList);
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final maintenances = await getIt<MaintenanceHttpService>().getAllMaintenances();
      final requests = await getIt<RequestHttpService>().getAllMaintenanceRequests();
      final equipments = await getIt<EquipmentHttpService>().getAllEquipments();
      if (mounted) {
        setState(() {
          _maintenances = maintenances;
          _requests = requests;
          _equipments = equipments;
          if (widget.repairService != null) {
            _selectedMaintenance = maintenances
                .where((m) => m.id == widget.repairService!.maintenance.id)
                .firstOrNull;
            _selectedRequest = requests
                .where((r) => r.id == widget.repairService!.maintenanceRequestDTO.id)
                .firstOrNull;
            _selectedEquipments = equipments
                .where((e) => widget.repairService!.equipmentList.any((se) => se.id == e.id))
                .toList();
          }
          _loadingOptions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _subTotalController.dispose();
    _finalPriceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaintenance == null || _selectedRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a empresa de manutenção e o request')),
      );
      return;
    }

    final model = RepairServiceModel(
      id: widget.repairService?.id ?? '',
      description: _descriptionController.text.trim(),
      subTotal: double.tryParse(_subTotalController.text) ?? 0,
      finalPrice: double.tryParse(_finalPriceController.text) ?? 0,
      maintenance: _selectedMaintenance!,
      maintenanceRequestDTO: RequestDTO(
        id: _selectedRequest!.id,
        requestNumber: _selectedRequest!.requestNumber,
        createdAt: _selectedRequest!.createdAt,
      ),
      equipmentList: _selectedEquipments,
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acService.createRepairService(model: model);
      } else {
        await widget.acService.updateRepairService(id: model.id, model: model);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar serviço: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.action == ActionEnum.view;
    final title = switch (widget.action) {
      ActionEnum.insert => 'Adicionar Serviço de Reparo',
      ActionEnum.edit => 'Editar Serviço de Reparo',
      _ => 'Detalhes do Serviço',
    };

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: _loadingOptions
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : isView
                ? _buildViewContent()
                : Form(key: _formKey, child: _buildFormContent()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(isView ? 'Fechar' : 'Cancelar'),
        ),
        if (!isView)
          ElevatedButton(
            onPressed: _save,
            child: Text(widget.action == ActionEnum.insert ? 'Salvar' : 'Atualizar'),
          ),
      ],
    );
  }

  Widget _buildViewContent() {
    final rs = widget.repairService!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow('Descrição', rs.description),
          _InfoRow('Subtotal', 'R\$ ${rs.subTotal.toStringAsFixed(2)}'),
          _InfoRow('Preço Final', 'R\$ ${rs.finalPrice.toStringAsFixed(2)}'),
          _InfoRow('Manutenção', rs.maintenance.name),
          _InfoRow('Request Nº', rs.maintenanceRequestDTO.requestNumber.toString()),
          if (rs.equipmentList.isNotEmpty) ...[
            const Divider(),
            const Text('Equipamentos', style: TextStyle(fontWeight: FontWeight.bold)),
            ...rs.equipmentList.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Text('• ${e.name} (${e.propertyNumber})'),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            maxLines: 2,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
          ),
          TextFormField(
            controller: _subTotalController,
            decoration: const InputDecoration(labelText: 'Subtotal (R\$)'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _finalPriceController,
            decoration: const InputDecoration(labelText: 'Preço Final (R\$)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<MaintenanceModel>(
            value: _selectedMaintenance,
            decoration: const InputDecoration(labelText: 'Empresa de Manutenção'),
            items: _maintenances
                .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMaintenance = v),
            validator: (v) => v == null ? 'Selecione a empresa' : null,
          ),
          DropdownButtonFormField<MaintenanceRequestModel>(
            value: _selectedRequest,
            decoration: const InputDecoration(labelText: 'Request de Manutenção'),
            items: _requests
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text('Nº ${r.requestNumber} — ${r.description}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedRequest = v),
            validator: (v) => v == null ? 'Selecione o request' : null,
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Equipamentos', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._equipments.map((e) => CheckboxListTile(
                dense: true,
                title: Text('${e.name} (${e.propertyNumber})'),
                value: _selectedEquipments.any((s) => s.id == e.id),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedEquipments.add(e);
                    } else {
                      _selectedEquipments.removeWhere((s) => s.id == e.id);
                    }
                  });
                },
              )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
