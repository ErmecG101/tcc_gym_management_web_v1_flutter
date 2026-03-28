import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/ac_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class DialogMaintenance extends StatefulWidget {
  const DialogMaintenance({
    super.key,
    required this.action,
    required this.acService,
    this.maintenance,
  });

  final ActionEnum action;
  final AcMaintenanceService acService;
  final MaintenanceModel? maintenance;

  @override
  State<DialogMaintenance> createState() => _DialogMaintenanceState();
}

class _DialogMaintenanceState extends State<DialogMaintenance> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _documentController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;

  List<GymModel> _gyms = [];
  GymModel? _selectedGym;
  bool _loadingGyms = true;

  @override
  void initState() {
    super.initState();
    final m = widget.maintenance;
    _nameController = TextEditingController(text: m?.name ?? '');
    _documentController = TextEditingController(text: m?.document ?? '');
    _phoneController = TextEditingController(text: m?.phoneNumber ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _contactController = TextEditingController(text: m?.contactEmployee ?? '');
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await getIt<GymHttpService>().getAllGyms();
      if (mounted) {
        setState(() {
          _gyms = gyms;
          _selectedGym = widget.maintenance != null
              ? gyms.where((g) => g.id == widget.maintenance!.gymDTO.id).firstOrNull
              : null;
          _loadingGyms = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingGyms = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGym == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a academia')),
      );
      return;
    }

    final model = MaintenanceModel(
      id: widget.maintenance?.id ?? '',
      name: _nameController.text.trim(),
      document: _documentController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      contactEmployee: _contactController.text.trim(),
      gymDTO: _selectedGym!,
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acService.createMaintenance(model: model);
      } else {
        await widget.acService.updateMaintenance(id: model.id, model: model);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar manutenção: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.action == ActionEnum.insert
        ? 'Adicionar Manutenção'
        : 'Editar Manutenção';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        child: _loadingGyms
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _documentController,
                        decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Telefone'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Endereço'),
                      ),
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(labelText: 'Funcionário de Contato'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<GymModel>(
                        value: _selectedGym,
                        decoration: const InputDecoration(labelText: 'Academia'),
                        items: _gyms
                            .map((g) => DropdownMenuItem(value: g, child: Text(g.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGym = v),
                        validator: (v) => v == null ? 'Selecione uma academia' : null,
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text(widget.action == ActionEnum.insert ? 'Salvar' : 'Atualizar'),
        ),
      ],
    );
  }
}
