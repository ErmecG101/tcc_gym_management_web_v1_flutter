import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/gym_services/ac_gym_service.dart';

class DialogGym extends StatefulWidget {
  const DialogGym({
    super.key,
    required this.action,
    required this.acGymService,
    this.gym,
  });

  final ActionEnum action;
  final AcGymService acGymService;
  final GymModel? gym;

  @override
  State<DialogGym> createState() => _DialogGymState();
}

class _DialogGymState extends State<DialogGym> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _documentController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gym?.name ?? '');
    _documentController = TextEditingController(text: widget.gym?.document ?? '');
    _phoneController = TextEditingController(text: widget.gym?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.gym?.email ?? '');
    _addressController = TextEditingController(text: widget.gym?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _documentController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final gym = GymModel(
      id: widget.gym?.id ?? '',
      name: _nameController.text.trim(),
      document: _documentController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    try {
      if (widget.action == ActionEnum.insert) {
        await widget.acGymService.createGym(gym: gym);
      } else {
        await widget.acGymService.updateGym(id: gym.id, gym: gym);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar academia: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.action == ActionEnum.insert ? 'Adicionar Academia' : 'Editar Academia';
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
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
                controller: _documentController,
                decoration: const InputDecoration(labelText: 'CNPJ'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
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
