import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/ac_equipment_type_service.dart';

class DialogEquipmentType extends StatefulWidget {
  const DialogEquipmentType({
    super.key,
    required this.action,
    required this.acService,
    this.equipmentType,
  });

  final ActionEnum action;
  final AcEquipmentTypeService acService;
  final EquipmentTypeModel? equipmentType;

  @override
  State<DialogEquipmentType> createState() => _DialogEquipmentTypeState();
}

class _DialogEquipmentTypeState extends State<DialogEquipmentType> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.equipmentType?.name ?? '');
    _descriptionController = TextEditingController(text: widget.equipmentType?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final model = EquipmentTypeModel(
      id: widget.equipmentType?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acService.createEquipmentType(model: model);
      } else {
        await widget.acService.updateEquipmentType(model: model);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tipo de equipamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.action == ActionEnum.insert
        ? 'Adicionar Tipo de Equipamento'
        : 'Editar Tipo de Equipamento';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
            ],
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
