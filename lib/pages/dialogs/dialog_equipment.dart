import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/constants/action_enum.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_type_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/gym_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/ac_equipment_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_type_services/equipment_type_http_service.dart';
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
  late final TextEditingController _originalValueController;
  late final TextEditingController _depreciationController;

  List<EquipmentTypeModel> _equipmentTypes = [];
  EquipmentTypeModel? _selectedType;
  GymModel? _userGym;
  DateTime? _purchaseDate;
  bool _loadingOptions = true;

  // Derived calculated current value (read-only display)
  double get _computedCurrentValue {
    final original = double.tryParse(_originalValueController.text.replaceAll(',', '.')) ?? 0;
    final depr = double.tryParse(_depreciationController.text.replaceAll(',', '.')) ?? 10;
    if (original <= 0 || _purchaseDate == null) return original;
    final now = DateTime.now();
    final months = (now.year - _purchaseDate!.year) * 12 + (now.month - _purchaseDate!.month);
    if (months <= 0) return original;
    final years = months / 12.0;
    final depreciated = original * (depr.clamp(0, 100) / 100) * years;
    return max(0, original - depreciated);
  }

  @override
  void initState() {
    super.initState();
    final e = widget.equipment;
    _nameController = TextEditingController(text: e?.name ?? '');
    _descriptionController = TextEditingController(text: e?.description ?? '');
    _propertyNumberController = TextEditingController(text: e?.propertyNumber ?? '');
    _originalValueController = TextEditingController(
      text: e != null ? e.originalValue.toStringAsFixed(2) : '',
    );
    _depreciationController = TextEditingController(
      text: e != null ? e.depreciationPercentage.toStringAsFixed(2) : '10.00',
    );

    // Parse existing purchase date from ISO string (YYYY-MM-...T...)
    if (e?.purchaseDate != null && e!.purchaseDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(e.purchaseDate);
        _purchaseDate = DateTime(dt.year, dt.month);
      } catch (_) {}
    }

    // Rebuild when values change to update the computed current value display
    _originalValueController.addListener(() => setState(() {}));
    _depreciationController.addListener(() => setState(() {}));

    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final types = await getIt<EquipmentTypeHttpService>().getAllEquipmentTypes();
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user');
      GymModel? gym;
      if (jsonStr != null) {
        final userJson = jsonDecode(jsonStr) as Map<String, dynamic>;
        final gymJson = userJson['gymDTO'] as Map<String, dynamic>?;
        gym = GymModel.fromJson(gymJson);
      }
      if (mounted) {
        setState(() {
          _equipmentTypes = types;
          _selectedType = widget.equipment != null
              ? types.where((t) => t.id == widget.equipment!.equipmentType.id).firstOrNull
              : null;
          _userGym = gym;
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
    _originalValueController.dispose();
    _depreciationController.dispose();
    super.dispose();
  }

  Future<void> _pickMonthYear() async {
    final initial = _purchaseDate ?? DateTime.now();
    int selectedYear = initial.year;
    int selectedMonth = initial.month;

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: const Text('Selecione Mês/Ano'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.toString().padLeft(2, '0')),
                        ))
                    .toList(),
                onChanged: (v) => setInner(() => selectedMonth = v!),
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(30, (i) => DateTime.now().year - i)
                    .map((y) => DropdownMenuItem(
                          value: y,
                          child: Text(y.toString()),
                        ))
                    .toList(),
                onChanged: (v) => setInner(() => selectedYear = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, DateTime(selectedYear, selectedMonth)),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  String _formatPurchaseDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _purchaseDateIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-01T00:00:00.000+00:00';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de equipamento')),
      );
      return;
    }
    if (_purchaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de compra')),
      );
      return;
    }
    if (_userGym == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível identificar a academia do usuário')),
      );
      return;
    }

    final deprValue = (double.tryParse(_depreciationController.text.replaceAll(',', '.')) ?? 10).clamp(0.0, 100.0);

    final model = EquipmentModel(
      id: widget.equipment?.id ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyNumber: _propertyNumberController.text.trim(),
      purchaseDate: _purchaseDateIso(_purchaseDate!),
      originalValue: double.tryParse(_originalValueController.text.replaceAll(',', '.')) ?? 0,
      currentValue: _computedCurrentValue,
      depreciationPercentage: deprValue,
      durability: 0,
      equipmentType: _selectedType!,
      gymDTO: _userGym!,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isView) ...[
                        _InfoRow('Nome', widget.equipment!.name),
                        _InfoRow('Descrição', widget.equipment!.description),
                        _InfoRow('Nº Patrimônio', widget.equipment!.propertyNumber),
                        _InfoRow('Data de Compra', _formatPurchaseDate(_purchaseDate)),
                        _InfoRow('Valor de Compra', 'R\$ ${widget.equipment!.originalValue.toStringAsFixed(2)}'),
                        _InfoRow('Depreciação', '${widget.equipment!.depreciationPercentage.toStringAsFixed(2)}%'),
                        _InfoRow('Valor Atual', 'R\$ ${_computedCurrentValue.toStringAsFixed(2)}'),
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
                        const SizedBox(height: 8),
                        // Month/Year date picker
                        InkWell(
                          onTap: _pickMonthYear,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Data de Compra (Mês/Ano)',
                              suffixIcon: const Icon(Icons.calendar_month),
                              errorText: _purchaseDate == null && _formKey.currentState != null
                                  ? 'Selecione a data de compra'
                                  : null,
                            ),
                            child: Text(
                              _purchaseDate != null
                                  ? _formatPurchaseDate(_purchaseDate)
                                  : 'Selecione...',
                              style: TextStyle(
                                color: _purchaseDate != null
                                    ? Theme.of(context).textTheme.bodyMedium?.color
                                    : Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _originalValueController,
                          decoration: const InputDecoration(
                            labelText: 'Valor de Compra (R\$)',
                            prefixText: 'R\$ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obrigatório';
                            final val = double.tryParse(v.replaceAll(',', '.'));
                            if (val == null || val <= 0) return 'Informe um valor válido';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _depreciationController,
                          decoration: const InputDecoration(
                            labelText: 'Depreciação Anual (%)',
                            suffixText: '%',
                            helperText: 'Padrão: 10% | Máximo: 100%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Obrigatório';
                            final val = double.tryParse(v.replaceAll(',', '.'));
                            if (val == null || val < 0) return 'Informe um percentual válido';
                            if (val > 100) return 'Máximo 100%';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        // Computed current value (read-only)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Valor Atual (calculado)',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'R\$ ${_computedCurrentValue.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
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
                        if (_userGym != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Academia: ${_userGym!.name}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
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
