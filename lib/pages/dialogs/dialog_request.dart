import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/ac_request_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class DialogRequest extends StatefulWidget {
  const DialogRequest({
    super.key,
    required this.action,
    this.request,
    this.acRequestService,
  });

  final ActionEnum action;
  final MaintenanceRequestModel? request;
  final AcRequestService? acRequestService;

  @override
  State<DialogRequest> createState() => _DialogRequestState();
}

class _DialogRequestState extends State<DialogRequest> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _observationController;

  // Insert mode extras
  List<MaintenanceModel> _maintenances = [];
  List<EquipmentModel> _equipments = [];
  MaintenanceModel? _selectedMaintenance;
  List<EquipmentModel> _selectedEquipments = [];
  UserModel? _loggedUser;
  bool _loadingOptions = false;

  bool get _isInsert => widget.action == ActionEnum.insert;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.request?.description ?? '',
    );
    _observationController = TextEditingController(
      text: widget.request?.observation ?? '',
    );
    if (_isInsert) _loadInsertOptions();
  }

  Future<void> _loadInsertOptions() async {
    setState(() => _loadingOptions = true);
    try {
      final maintenances = await getIt<MaintenanceHttpService>().getAllMaintenances();
      final equipments = await getIt<EquipmentHttpService>().getAllEquipments();
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user');
      UserModel? user;
      if (jsonStr != null) {
        user = UserModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>?);
      }
      if (mounted) {
        setState(() {
          _maintenances = maintenances;
          _equipments = equipments;
          _loggedUser = user;
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
    _observationController.dispose();
    super.dispose();
  }

  String _nowFormatted() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> _createPedido() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMaintenance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a empresa de manutenção')),
      );
      return;
    }
    if (_selectedEquipments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos um equipamento')),
      );
      return;
    }
    if (_loggedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não identificado. Faça login novamente.')),
      );
      return;
    }

    final request = MaintenanceRequestModel(
      id: '',
      requestNumber: 0,
      description: _descriptionController.text.trim(),
      observation: _observationController.text.trim().isEmpty
          ? null
          : _observationController.text.trim(),
      createdAt: _nowFormatted(),
      maintenanceDTO: MaintenanceDTO(
        id: _selectedMaintenance!.id,
        name: _selectedMaintenance!.name,
        phone: _selectedMaintenance!.phoneNumber,
        document: _selectedMaintenance!.document,
      ),
      userDTO: UserDTO(
        id: _loggedUser!.id,
        name: _loggedUser!.name,
        email: _loggedUser!.email,
        document: _loggedUser!.document,
      ),
      equipments: _selectedEquipments,
      maintenances: [],
      conditions: [],
    );

    try {
      await widget.acRequestService!.createRequest(request: request);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pedido: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.action) {
      ActionEnum.insert => 'Novo Pedido de Manutenção',
      ActionEnum.view => 'Detalhes do Pedido',
      _ => 'Editar Pedido',
    };

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: _isInsert
            ? (_loadingOptions
                ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
                : Form(key: _formKey, child: _buildInsertForm()))
            : Form(key: _formKey, child: _buildViewEditForm()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Fechar'),
        ),
        if (_isInsert)
          ElevatedButton(
            onPressed: _createPedido,
            child: const Text('Criar Pedido'),
          ),
      ],
    );
  }

  Widget _buildInsertForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descrição'),
            maxLines: 3,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Descrição é obrigatória' : null,
          ),
          TextFormField(
            controller: _observationController,
            decoration: const InputDecoration(labelText: 'Observação (opcional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<MaintenanceModel>(
            value: _selectedMaintenance,
            decoration: const InputDecoration(labelText: 'Empresa de Manutenção'),
            items: _maintenances
                .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMaintenance = v),
            validator: (v) => v == null ? 'Selecione a empresa de manutenção' : null,
          ),
          const SizedBox(height: 12),
          const Text('Equipamentos *', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text(
            'Selecione ao menos um equipamento',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          ..._equipments.map((e) => CheckboxListTile(
                dense: true,
                title: Text('${e.name} (${e.propertyNumber})'),
                subtitle: Text(e.equipmentType.name, style: const TextStyle(fontSize: 12)),
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

  Widget _buildViewEditForm() {
    final req = widget.request!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Código', value: req.requestNumber.toString()),
          _InfoRow(label: 'Criado em', value: req.createdAt),
          if (req.updatedAt != null)
            _InfoRow(label: 'Atualizado em', value: req.updatedAt!),
          if (req.closedAt != null)
            _InfoRow(label: 'Encerrado em', value: req.closedAt!),
          const Divider(),
          _InfoRow(label: 'Descrição', value: req.description),
          if (req.observation != null && req.observation!.isNotEmpty)
            _InfoRow(label: 'Observação', value: req.observation!),
          const Divider(),
          _InfoRow(label: 'Manutenção', value: req.maintenanceDTO.name),
          _InfoRow(label: 'Telefone', value: req.maintenanceDTO.phone),
          _InfoRow(label: 'Solicitante', value: req.userDTO.name),
          _InfoRow(label: 'Email', value: req.userDTO.email),
          if (req.equipments.isNotEmpty) ...[
            const Divider(),
            const Text('Equipamentos', style: TextStyle(fontWeight: FontWeight.bold)),
            ...req.equipments
                .where((e) => e.id.isNotEmpty)
                .map((e) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text('• ${e.name} (${e.propertyNumber})'),
                    )),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
