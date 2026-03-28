import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/ac_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/gym_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class DialogEquipment extends StatefulWidget {
  const DialogEquipment({
    super.key,
    required this.action,
    required this.acService,
    this.equipment,
  });

  final ActionEnum action;
  final AcEquipmentService acService;
  final EquipmentModel? equipment;

  @override
  State<DialogEquipment> createState() => _DialogEquipmentState();
}

class _DialogEquipmentState extends State<DialogEquipment> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _propertyNumberController;
  late final TextEditingController _purchaseDateController;
  late final TextEditingController _originalValueController;
  late final TextEditingController _currentValueController;
  late final TextEditingController _depreciationController;
  late final TextEditingController _durabilityController;

  List<EquipmentTypeModel> _equipmentTypes = [];
  List<GymModel> _gyms = [];
  EquipmentTypeModel? _selectedType;
  GymModel? _selectedGym;
  bool _loadingOptions = true;

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _propertyNumberController = TextEditingController(text: e?.propertyNumber ?? '');
    _purchaseDateController = TextEditingController(text: e?.purchaseDate ?? '');
    _originalValueController = TextEditingController(
      text: e != null ? e.originalValue.toString() : '',
    );
    _currentValueController = TextEditingController(
      text: e != null ? e.currentValue.toString() : '',
    );
    _depreciationController = TextEditingController(
      text: e != null ? e.depreciationPercentage.toString() : '',
    );
    _durabilityController = TextEditingController(
      text: e != null ? e.durability.toString() : '',
    );
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final types = await getIt<EquipmentTypeHttpService>().getAllEquipmentTypes();
      final gyms = await getIt<GymHttpService>().getAllGyms();
      if (mounted) {
        setState(() {
          _equipmentTypes = types;
          _gyms = gyms;
          _selectedType = widget.equipment != null
              ? types.where((t) => t.id == widget.equipment!.equipmentType.id).firstOrNull
              : null;
          _selectedGym = widget.equipment != null
              ? gyms.where((g) => g.id == widget.equipment!.gymDTO.id).firstOrNull
              : null;
          _loadingOptions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingOptions = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _propertyNumberController.dispose();
    _purchaseDateController.dispose();
    _originalValueController.dispose();
    _currentValueController.dispose();
    _depreciationController.dispose();
    _durabilityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedGym == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo e a academia')),
      );
      return;
    }

    final model = EquipmentModel(
      id: widget.equipment?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyNumber: _propertyNumberController.text.trim(),
      purchaseDate: _purchaseDateController.text.trim(),
      originalValue: double.tryParse(_originalValueController.text) ?? 0,
      currentValue: double.tryParse(_currentValueController.text) ?? 0,
      depreciationPercentage: double.tryParse(_depreciationController.text) ?? 0,
      durability: double.tryParse(_durabilityController.text) ?? 0,
      equipmentType: _selectedType!,
      gymDTO: _selectedGym!,
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acService.createEquipment(model: model);
      } else {
        await widget.acService.updateEquipment(id: model.id, model: model);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar equipamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.action == ActionEnum.view;
    final title = switch (widget.action) {
      ActionEnum.insert => 'Adicionar Equipamento',
      ActionEnum.edit => 'Editar Equipamento',
      _ => 'Detalhes do Equipamento',
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
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isView) ...[
                        _InfoRow('Nome', widget.equipment!.name),
                        _InfoRow('Descrição', widget.equipment!.description),
                        _InfoRow('Nº Patrimônio', widget.equipment!.propertyNumber),
                        _InfoRow('Data de Compra', widget.equipment!.purchaseDate),
                        _InfoRow('Valor Original', widget.equipment!.originalValue.toString()),
                        _InfoRow('Valor Atual', widget.equipment!.currentValue.toString()),
                        _InfoRow('Depreciação %', widget.equipment!.depreciationPercentage.toString()),
                        _InfoRow('Durabilidade %', widget.equipment!.durability.toString()),
                        _InfoRow('Tipo', widget.equipment!.equipmentType.name),
                        _InfoRow('Academia', widget.equipment!.gymDTO.name),
                      ] else ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Descrição'),
                        ),
                        TextFormField(
                          controller: _propertyNumberController,
                          decoration: const InputDecoration(labelText: 'Nº Patrimônio'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                        ),
                        TextFormField(
                          controller: _purchaseDateController,
                          decoration: const InputDecoration(
                            labelText: 'Data de Compra',
                            hintText: 'YYYY-MM-DD',
                          ),
                        ),
                        TextFormField(
                          controller: _originalValueController,
                          decoration: const InputDecoration(labelText: 'Valor Original (R\$)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: _currentValueController,
                          decoration: const InputDecoration(labelText: 'Valor Atual (R\$)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: _depreciationController,
                          decoration: const InputDecoration(labelText: 'Depreciação (%)'),
                          keyboardType: TextInputType.number,
                        ),
                        TextFormField(
                          controller: _durabilityController,
                          decoration: const InputDecoration(labelText: 'Durabilidade (%)'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<EquipmentTypeModel>(
                          value: _selectedType,
                          decoration: const InputDecoration(labelText: 'Tipo de Equipamento'),
                          items: _equipmentTypes
                              .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedType = v),
                          validator: (v) => v == null ? 'Selecione um tipo' : null,
                        ),
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
                    ],
                  ),
                ),
              ),
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
            width: 140,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
