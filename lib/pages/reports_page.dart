import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

enum _ReportType {
  inventario('Inventário de Equipamentos', Icons.list_alt),
  depreciacao('Depreciação por Equipamento', Icons.trending_down),
  valorPatrimonial('Valor Patrimonial Total', Icons.account_balance_wallet),
  equipamentosPorTipo('Equipamentos por Tipo', Icons.category),
  altaDepreciacao('Alta Depreciação (> 50%)', Icons.warning_amber_rounded),
  historicoRequisicoes('Histórico de Pedidos', Icons.history),
  custoPorEmpresa('Custo por Empresa de Manutenção', Icons.engineering);

  const _ReportType(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─── Table cell helpers ───────────────────────────────────────────────────────

Widget _th(String label) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );

Widget _td(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: child,
    );

// ─── Page ─────────────────────────────────────────────────────────────────────

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _loading = true;
  String? _error;
  _ReportType _selected = _ReportType.inventario;

  List<EquipmentModel> _equipments = [];
  List<RepairServiceModel> _repairServices = [];
  List<MaintenanceRequestModel> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        getIt<EquipmentHttpService>().getAllEquipments(),
        getIt<RepairServiceHttpService>().getAllRepairServices(),
        getIt<RequestHttpService>().getAllMaintenanceRequests(),
      ]);
      if (mounted) {
        setState(() {
          _equipments = results[0] as List<EquipmentModel>;
          _repairServices = results[1] as List<RepairServiceModel>;
          _requests = results[2] as List<MaintenanceRequestModel>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  static String _fmt(double v) =>
      'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+,)'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Relatórios',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const Text('Erro ao carregar dados'),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Relatórios',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton.outlined(
                tooltip: 'Atualizar dados',
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
            ],
          ),
          _ReportSelector(
            selected: _selected,
            onSelected: (t) => setState(() => _selected = t),
          ),
          _buildReport(),
        ],
      ),
    );
  }

  Widget _buildReport() {
    return switch (_selected) {
      _ReportType.inventario => _InventarioReport(equipments: _equipments, fmt: _fmt),
      _ReportType.depreciacao => _DepreciacaoReport(equipments: _equipments, fmt: _fmt),
      _ReportType.valorPatrimonial => _ValorPatrimonialReport(equipments: _equipments, fmt: _fmt),
      _ReportType.equipamentosPorTipo => _PorTipoReport(equipments: _equipments, fmt: _fmt),
      _ReportType.altaDepreciacao => _AltaDepreciacaoReport(equipments: _equipments, fmt: _fmt),
      _ReportType.historicoRequisicoes => _HistoricoRequisicoes(requests: _requests),
      _ReportType.custoPorEmpresa => _CustoPorEmpresaReport(services: _repairServices, fmt: _fmt),
    };
  }
}

// ─── Report Selector ──────────────────────────────────────────────────────────

class _ReportSelector extends StatelessWidget {
  const _ReportSelector({required this.selected, required this.onSelected});
  final _ReportType selected;
  final ValueChanged<_ReportType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _ReportType.values.map((type) {
        final isSelected = type == selected;
        final cs = Theme.of(context).colorScheme;
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Icon(type.icon, size: 18, color: isSelected ? cs.onPrimary : cs.onSurfaceVariant),
                Text(
                  type.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Report Card Shell ────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: Theme.of(context).colorScheme.outlineVariant),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ─── Full-width table builder ─────────────────────────────────────────────────

Widget _buildTable({
  required BuildContext context,
  required Map<int, TableColumnWidth> columnWidths,
  required List<Widget> headers,
  required List<TableRow> dataRows,
}) {
  final headingBg = Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
  final divider = Theme.of(context).dividerColor;
  return Table(
    columnWidths: columnWidths,
    border: TableBorder(horizontalInside: BorderSide(color: divider, width: 0.5)),
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: [
      TableRow(
        decoration: BoxDecoration(color: headingBg),
        children: headers,
      ),
      ...dataRows,
    ],
  );
}

// ─── 1. Inventário de Equipamentos ───────────────────────────────────────────

class _InventarioReport extends StatelessWidget {
  const _InventarioReport({required this.equipments, required this.fmt});
  final List<EquipmentModel> equipments;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      title: 'Inventário de Equipamentos',
      subtitle: '${equipments.length} equipamento(s) cadastrado(s)',
      child: equipments.isEmpty
          ? const _EmptyState('Nenhum equipamento cadastrado.')
          : _buildTable(
              context: context,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
                6: FlexColumnWidth(1),
              },
              headers: [
                _th('Nome'), _th('Nº Patrimônio'), _th('Tipo'),
                _th('Data de Compra'), _th('Valor Original'),
                _th('Valor Atual'), _th('Vida Útil (anos)'),
              ],
              dataRows: equipments.map((e) => TableRow(children: [
                _td(Text(e.name)),
                _td(Text(e.propertyNumber)),
                _td(Text(e.equipmentType.name)),
                _td(Text(e.purchaseDate.isNotEmpty ? e.purchaseDate.substring(0, 10) : '—')),
                _td(Text(fmt(e.originalValue))),
                _td(Text(fmt(e.currentValue))),
                _td(Text(e.durability.toStringAsFixed(1))),
              ])).toList(),
            ),
    );
  }
}

// ─── 2. Depreciação por Equipamento ──────────────────────────────────────────

class _DepreciacaoReport extends StatelessWidget {
  const _DepreciacaoReport({required this.equipments, required this.fmt});
  final List<EquipmentModel> equipments;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final sorted = [...equipments]..sort((a, b) {
        final aPct = a.originalValue > 0 ? (a.originalValue - a.currentValue) / a.originalValue : 0.0;
        final bPct = b.originalValue > 0 ? (b.originalValue - b.currentValue) / b.originalValue : 0.0;
        return bPct.compareTo(aPct);
      });

    return _ReportCard(
      title: 'Depreciação por Equipamento',
      subtitle: 'Ordenado do mais ao menos depreciado',
      child: equipments.isEmpty
          ? const _EmptyState('Nenhum equipamento cadastrado.')
          : _buildTable(
              context: context,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
                6: FlexColumnWidth(1),
              },
              headers: [
                _th('Nome'), _th('Tipo'), _th('Valor Original'),
                _th('Valor Atual'), _th('Depreciação (R\$)'),
                _th('Depreciação (%)'), _th('Taxa a.a.'),
              ],
              dataRows: sorted.map((e) {
                final loss = e.originalValue - e.currentValue;
                final pct = e.originalValue > 0 ? (loss / e.originalValue) * 100 : 0.0;
                final color = pct < 30 ? Colors.green : pct < 60 ? Colors.orange : Colors.red;
                return TableRow(children: [
                  _td(Text(e.name)),
                  _td(Text(e.equipmentType.name)),
                  _td(Text(fmt(e.originalValue))),
                  _td(Text(fmt(e.currentValue))),
                  _td(Text(fmt(loss), style: TextStyle(color: Colors.red.shade700))),
                  _td(Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${pct.toStringAsFixed(1)}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  )),
                  _td(Text('${e.depreciationPercentage.toStringAsFixed(2)}%')),
                ]);
              }).toList(),
            ),
    );
  }
}

// ─── 3. Valor Patrimonial Total ───────────────────────────────────────────────

class _ValorPatrimonialReport extends StatelessWidget {
  const _ValorPatrimonialReport({required this.equipments, required this.fmt});
  final List<EquipmentModel> equipments;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final totalOriginal = equipments.fold<double>(0, (s, e) => s + e.originalValue);
    final totalCurrent = equipments.fold<double>(0, (s, e) => s + e.currentValue);
    final totalLoss = totalOriginal - totalCurrent;
    final pct = totalOriginal > 0 ? totalLoss / totalOriginal : 0.0;
    final color = pct < 0.3 ? Colors.green : pct < 0.6 ? Colors.orange : Colors.red;

    final byType = <String, _TypeSummary>{};
    for (final e in equipments) {
      final key = e.equipmentType.name.isNotEmpty ? e.equipmentType.name : 'Sem tipo';
      byType.putIfAbsent(key, () => _TypeSummary());
      byType[key]!.count++;
      byType[key]!.original += e.originalValue;
      byType[key]!.current += e.currentValue;
    }

    return _ReportCard(
      title: 'Valor Patrimonial Total',
      subtitle: 'Consolidado de todos os equipamentos',
      child: equipments.isEmpty
          ? const _EmptyState('Nenhum equipamento cadastrado.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Expanded(child: _ValueTile(label: 'Valor Total de Compra', value: fmt(totalOriginal), color: Colors.blue)),
                    Expanded(child: _ValueTile(label: 'Valor Atual Total', value: fmt(totalCurrent), color: Colors.green)),
                    Expanded(child: _ValueTile(label: 'Depreciação Acumulada', value: fmt(totalLoss), color: Colors.red)),
                    Expanded(
                      child: _ValueTile(
                        label: 'Depreciação Geral',
                        value: '${(pct * 100).toStringAsFixed(1)}%',
                        color: color,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text('Perda patrimonial acumulada', style: Theme.of(context).textTheme.bodySmall),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: Colors.red.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                  ],
                ),
                if (byType.isNotEmpty) ...[
                  Text(
                    'Detalhamento por Tipo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _buildTable(
                    context: context,
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(2),
                      3: FlexColumnWidth(2),
                      4: FlexColumnWidth(2),
                    },
                    headers: [_th('Tipo'), _th('Qtd.'), _th('Valor Original'), _th('Valor Atual'), _th('Depreciação')],
                    dataRows: byType.entries.map((entry) {
                      final s = entry.value;
                      final loss = s.original - s.current;
                      return TableRow(children: [
                        _td(Text(entry.key)),
                        _td(Text(s.count.toString())),
                        _td(Text(fmt(s.original))),
                        _td(Text(fmt(s.current))),
                        _td(Text(fmt(loss), style: TextStyle(color: Colors.red.shade700))),
                      ]);
                    }).toList(),
                  ),
                ],
              ],
            ),
    );
  }
}

class _TypeSummary {
  int count = 0;
  double original = 0;
  double current = 0;
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ─── 4. Equipamentos por Tipo ─────────────────────────────────────────────────

class _PorTipoReport extends StatelessWidget {
  const _PorTipoReport({required this.equipments, required this.fmt});
  final List<EquipmentModel> equipments;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final byType = <String, List<EquipmentModel>>{};
    for (final e in equipments) {
      final key = e.equipmentType.name.isNotEmpty ? e.equipmentType.name : 'Sem tipo';
      byType.putIfAbsent(key, () => []).add(e);
    }
    final sorted = byType.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));

    return _ReportCard(
      title: 'Equipamentos por Tipo',
      subtitle: '${byType.length} tipo(s) de equipamento',
      child: equipments.isEmpty
          ? const _EmptyState('Nenhum equipamento cadastrado.')
          : Column(
              spacing: 16,
              children: sorted.map((entry) {
                final list = entry.value;
                final totalOrig = list.fold<double>(0, (s, e) => s + e.originalValue);
                final totalCurr = list.fold<double>(0, (s, e) => s + e.currentValue);
                return ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${list.length} equipamento(s) · ${fmt(totalCurr)} valor atual'),
                  trailing: Chip(
                    label: Text('${list.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Column(
                        spacing: 8,
                        children: [
                          Row(
                            spacing: 16,
                            children: [
                              Expanded(child: _ValueTile(label: 'Valor Original Total', value: fmt(totalOrig), color: Colors.blue)),
                              Expanded(child: _ValueTile(label: 'Valor Atual Total', value: fmt(totalCurr), color: Colors.green)),
                              Expanded(child: _ValueTile(label: 'Depreciação Total', value: fmt(totalOrig - totalCurr), color: Colors.red)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _buildTable(
                            context: context,
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1.5),
                              2: FlexColumnWidth(1.5),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1),
                            },
                            headers: [
                              _th('Nome'), _th('Nº Patrimônio'), _th('Valor Original'),
                              _th('Valor Atual'), _th('Depreciação (%)'),
                            ],
                            dataRows: list.map((e) {
                              final pct = e.originalValue > 0
                                  ? ((e.originalValue - e.currentValue) / e.originalValue) * 100
                                  : 0.0;
                              return TableRow(children: [
                                _td(Text(e.name)),
                                _td(Text(e.propertyNumber)),
                                _td(Text(fmt(e.originalValue))),
                                _td(Text(fmt(e.currentValue))),
                                _td(Text('${pct.toStringAsFixed(1)}%')),
                              ]);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

// ─── 5. Alta Depreciação ──────────────────────────────────────────────────────

class _AltaDepreciacaoReport extends StatelessWidget {
  const _AltaDepreciacaoReport({required this.equipments, required this.fmt});
  final List<EquipmentModel> equipments;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final highDeprec = equipments.where((e) {
      final pct = e.originalValue > 0 ? (e.originalValue - e.currentValue) / e.originalValue : 0.0;
      return pct >= 0.5;
    }).toList()
      ..sort((a, b) {
        final aPct = a.originalValue > 0 ? (a.originalValue - a.currentValue) / a.originalValue : 0.0;
        final bPct = b.originalValue > 0 ? (b.originalValue - b.currentValue) / b.originalValue : 0.0;
        return bPct.compareTo(aPct);
      });

    return _ReportCard(
      title: 'Equipamentos com Alta Depreciação (> 50%)',
      subtitle: highDeprec.isEmpty
          ? 'Nenhum equipamento com depreciação acima de 50%'
          : '${highDeprec.length} equipamento(s) necessitam atenção',
      child: highDeprec.isEmpty
          ? SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  const Icon(Icons.check_circle_outline, size: 40, color: Colors.green),
                  Text(
                    'Todos os equipamentos estão dentro do limite aceitável de depreciação.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              spacing: 12,
              children: highDeprec.map((e) {
                final loss = e.originalValue - e.currentValue;
                final pct = e.originalValue > 0 ? (loss / e.originalValue).clamp(0.0, 1.0) : 0.0;
                final color = pct < 0.7 ? Colors.orange : Colors.red;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${e.equipmentType.name} · Nº ${e.propertyNumber}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(pct * 100).toStringAsFixed(1)}% depreciado',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      Row(
                        spacing: 16,
                        children: [
                          Text('Valor original: ${fmt(e.originalValue)}', style: Theme.of(context).textTheme.bodySmall),
                          Text('Valor atual: ${fmt(e.currentValue)}', style: Theme.of(context).textTheme.bodySmall),
                          Text(
                            'Perda: ${fmt(loss)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─── 6. Histórico de Pedidos ──────────────────────────────────────────────────

class _HistoricoRequisicoes extends StatefulWidget {
  const _HistoricoRequisicoes({required this.requests});
  final List<MaintenanceRequestModel> requests;

  @override
  State<_HistoricoRequisicoes> createState() => _HistoricoRequisicoesState();
}

class _HistoricoRequisicoesState extends State<_HistoricoRequisicoes> {
  bool _showOpenOnly = false;

  @override
  Widget build(BuildContext context) {
    final filtered = _showOpenOnly
        ? widget.requests.where((r) => r.closedAt == null).toList()
        : widget.requests;
    final openCount = widget.requests.where((r) => r.closedAt == null).length;
    final closedCount = widget.requests.length - openCount;

    return _ReportCard(
      title: 'Histórico de Pedidos de Manutenção',
      subtitle: '${widget.requests.length} pedido(s) no total · $openCount aberto(s) · $closedCount encerrado(s)',
      child: widget.requests.isEmpty
          ? const _EmptyState('Nenhum pedido encontrado.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Apenas abertos'),
                  selected: _showOpenOnly,
                  onSelected: (v) => setState(() => _showOpenOnly = v),
                ),
                _buildTable(
                  context: context,
                  columnWidths: const {
                    0: FixedColumnWidth(60),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FixedColumnWidth(100),
                    5: FixedColumnWidth(110),
                    6: FixedColumnWidth(100),
                  },
                  headers: [
                    _th('Nº'), _th('Descrição'), _th('Empresa'),
                    _th('Responsável'), _th('Aberto em'),
                    _th('Encerrado em'), _th('Status'),
                  ],
                  dataRows: filtered.map((r) {
                    final isOpen = r.closedAt == null;
                    final statusColor = isOpen ? Colors.orange : Colors.green;
                    return TableRow(children: [
                      _td(Text('#${r.requestNumber}')),
                      _td(Text(r.description, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      _td(Text(r.maintenanceDTO.name)),
                      _td(Text(r.userDTO.name)),
                      _td(Text(r.createdAt.isNotEmpty ? r.createdAt.substring(0, 10) : '—')),
                      _td(Text(r.closedAt != null ? r.closedAt!.substring(0, 10) : '—')),
                      _td(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isOpen ? 'Aberto' : 'Encerrado',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      )),
                    ]);
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

// ─── 7. Custo por Empresa de Manutenção ──────────────────────────────────────

class _CustoPorEmpresaReport extends StatelessWidget {
  const _CustoPorEmpresaReport({required this.services, required this.fmt});
  final List<RepairServiceModel> services;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final byCompany = <String, _CompanySummary>{};
    for (final s in services) {
      final key = s.maintenance.name.isNotEmpty ? s.maintenance.name : 'Sem empresa';
      byCompany.putIfAbsent(key, () => _CompanySummary());
      byCompany[key]!.count++;
      byCompany[key]!.subTotal += s.subTotal;
      byCompany[key]!.finalPrice += s.finalPrice;
    }
    final sorted = byCompany.entries.toList()
      ..sort((a, b) => b.value.finalPrice.compareTo(a.value.finalPrice));

    final totalFinal = services.fold<double>(0, (s, r) => s + r.finalPrice);
    final totalSub = services.fold<double>(0, (s, r) => s + r.subTotal);

    return _ReportCard(
      title: 'Custo por Empresa de Manutenção',
      subtitle: '${services.length} serviço(s) · ${byCompany.length} empresa(s)',
      child: services.isEmpty
          ? const _EmptyState('Nenhum serviço de reparo registrado.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Expanded(child: _ValueTile(label: 'Total de Serviços', value: services.length.toString(), color: Colors.blue)),
                    Expanded(child: _ValueTile(label: 'Subtotal Geral', value: fmt(totalSub), color: Colors.orange)),
                    Expanded(child: _ValueTile(label: 'Total Final Geral', value: fmt(totalFinal), color: Colors.green)),
                  ],
                ),
                _buildTable(
                  context: context,
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(2),
                  },
                  headers: [
                    _th('Empresa'), _th('Qtd. Serviços'), _th('Subtotal'),
                    _th('Total Final'), _th('% do Total'),
                  ],
                  dataRows: sorted.map((entry) {
                    final s = entry.value;
                    final share = totalFinal > 0 ? (s.finalPrice / totalFinal) * 100 : 0.0;
                    return TableRow(children: [
                      _td(Text(entry.key)),
                      _td(Text(s.count.toString())),
                      _td(Text(fmt(s.subTotal))),
                      _td(Text(fmt(s.finalPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                      _td(Row(
                        spacing: 8,
                        children: [
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: (share / 100).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ),
                          Text('${share.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ],
            ),
    );
  }
}

class _CompanySummary {
  int count = 0;
  double subTotal = 0;
  double finalPrice = 0;
}
