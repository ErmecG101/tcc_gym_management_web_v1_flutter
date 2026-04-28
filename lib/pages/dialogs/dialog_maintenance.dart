import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/ac_maintenance_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/utils/input_formatters.dart';

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

  String _documentType = 'CPF'; // 'CPF' or 'CNPJ'
  GymModel? _userGym;
  bool _loading = true;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

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

    // Guess document type from existing value length
    if (m != null) {
      final digits = m.document.replaceAll(RegExp(r'\D'), '');
      _documentType = digits.length > 11 ? 'CNPJ' : 'CPF';
    }

    _loadUserGym();
  }

  Future<void> _loadUserGym() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user');
      if (jsonStr != null) {
        final userJson = jsonDecode(jsonStr) as Map<String, dynamic>;
        final gymJson = userJson['gymDTO'] as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _userGym = GymModel.fromJson(gymJson);
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
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
    if (_userGym == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar a academia do usuário')),
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
      gymDTO: _userGym!,
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
          SnackBar(content: Text('Erro ao salvar empresa de manutenção: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isView = widget.action == ActionEnum.view;
    final title = switch (widget.action) {
      ActionEnum.insert => 'Adicionar Empresa de Manutenção',
      ActionEnum.edit => 'Editar Empresa de Manutenção',
      _ => 'Detalhes da Empresa de Manutenção',
    };

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        child: _loading
            ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
            : isView
                ? _buildView()
                : Form(key: _formKey, child: _buildForm()),
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

  Widget _buildView() {
    final m = widget.maintenance!;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoRow('Nome', m.name),
          _InfoRow('Documento', m.document),
          _InfoRow('Telefone', m.phoneNumber),
          _InfoRow('Email', m.email),
          _InfoRow('Endereço', m.address),
          _InfoRow('Func. Contato', m.contactEmployee),
          _InfoRow('Academia', m.gymDTO.name),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final formatter = _documentType == 'CPF'
        ? CpfInputFormatter()
        : CnpjInputFormatter();
    final maxDocLength = _documentType == 'CPF' ? 14 : 18; // with mask chars

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
          ),
          const SizedBox(height: 8),
          // Document type selector + field
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: _documentType,
                items: const [
                  DropdownMenuItem(value: 'CPF', child: Text('CPF')),
                  DropdownMenuItem(value: 'CNPJ', child: Text('CNPJ')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _documentType = v;
                      _documentController.clear();
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  key: ValueKey(_documentType),
                  controller: _documentController,
                  decoration: InputDecoration(labelText: _documentType),
                  keyboardType: TextInputType.number,
                  inputFormatters: [formatter],
                  maxLength: maxDocLength,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obrigatório';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    final expected = _documentType == 'CPF' ? 11 : 14;
                    if (digits.length != expected) return '$_documentType incompleto';
                    return null;
                  },
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Telefone'),
            keyboardType: TextInputType.phone,
            inputFormatters: [PhoneInputFormatter()],
            maxLength: 15,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Obrigatório';
              final digits = v.replaceAll(RegExp(r'\D'), '');
              if (digits.length < 10) return 'Telefone inválido';
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Obrigatório';
              if (!_emailRegex.hasMatch(v.trim())) return 'Email inválido';
              return null;
            },
          ),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Endereço'),
          ),
          TextFormField(
            controller: _contactController,
            decoration: const InputDecoration(labelText: 'Funcionário de Contato'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
          ),
          if (_userGym != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Academia: ${_userGym!.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ),
          ],
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
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
