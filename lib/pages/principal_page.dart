import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/equipment_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/maintenance_request_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/repair_service_model.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/equipment_services/equipment_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/maintenance_services/maintenance_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/repair_service_services/repair_service_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/request_services/request_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/service/user_services/user_http_service.dart';
import 'package:tcc_gym_management_web_v1_flutter/pages/components/custom_scaffold.dart';
import 'package:tcc_gym_management_web_v1_flutter/service_locator.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _DashboardData {
  final String userName;
  final String gymName;
  final int equipmentCount;
  final int openRequestsCount;
  final int repairServicesCount;
  final int maintenanceCompaniesCount;
  final int usersCount;
  final double totalOriginalValue;
  final double totalCurrentValue;
  final List<MaintenanceRequestModel> recentRequests;
  final List<EquipmentModel> mostDepreciatedEquipments;
  final List<RepairServiceModel> repairServices;

  _DashboardData({
    required this.userName,
    required this.gymName,
    required this.equipmentCount,
    required this.openRequestsCount,
    required this.repairServicesCount,
    required this.maintenanceCompaniesCount,
    required this.usersCount,
    required this.totalOriginalValue,
    required this.totalCurrentValue,
    required this.recentRequests,
    required this.mostDepreciatedEquipments,
    required this.repairServices,
  });

  double get totalDepreciation => totalOriginalValue - totalCurrentValue;
  double get depreciationPercent =>
      totalOriginalValue > 0 ? (totalDepreciation / totalOriginalValue) : 0;
}

class _PrincipalPageState extends State<PrincipalPage> {
  _DashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      String userName = '';
      String gymName = '';
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        userName = map['name'] as String? ?? '';
        final gymMap = map['gymDTO'] as Map<String, dynamic>?;
        gymName = gymMap?['name'] as String? ?? '';
      }

      final equipments = await getIt<EquipmentHttpService>().getAllEquipments();
      final requests = await getIt<RequestHttpService>().getAllMaintenanceRequests();
      final repairServices = await getIt<RepairServiceHttpService>().getAllRepairServices();
      final maintenances = await getIt<MaintenanceHttpService>().getAllMaintenances();
      final users = await getIt<UserHttpService>().getAllUsers();

      final openRequests =
          requests.where((r) => r.closedAt == null).toList();

      final totalOriginal =
          equipments.fold<double>(0, (sum, e) => sum + e.originalValue);
      final totalCurrent =
          equipments.fold<double>(0, (sum, e) => sum + e.currentValue);

      final recentRequests = [...requests]
        ..sort((a, b) => b.requestNumber.compareTo(a.requestNumber));

      final mostDeprec = [...equipments]
        ..sort((a, b) {
          final aLoss = a.originalValue > 0
              ? (a.originalValue - a.currentValue) / a.originalValue
              : 0.0;
          final bLoss = b.originalValue > 0
              ? (b.originalValue - b.currentValue) / b.originalValue
              : 0.0;
          return bLoss.compareTo(aLoss);
        });

      if (mounted) {
        setState(() {
          _data = _DashboardData(
            userName: userName,
            gymName: gymName,
            equipmentCount: equipments.length,
            openRequestsCount: openRequests.length,
            repairServicesCount: repairServices.length,
            maintenanceCompaniesCount: maintenances.length,
            usersCount: users.length,
            totalOriginalValue: totalOriginal,
            totalCurrentValue: totalCurrent,
            recentRequests: recentRequests.take(5).toList(),
            mostDepreciatedEquipments: mostDeprec.take(5).toList(),
            repairServices: repairServices,
          );
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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Dashboard',
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildDashboard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text('Erro ao carregar dados do dashboard'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final d = _data!;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo, ${d.userName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    d.gymName.isNotEmpty ? 'Academia: ${d.gymName}' : '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              IconButton.outlined(
                tooltip: 'Atualizar',
                icon: const Icon(Icons.refresh),
                onPressed: _loadDashboard,
              ),
            ],
          ),

          // KPI Cards row
          _KpiRow(data: d),

          // Middle section: Financial summary + Recent requests
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              Expanded(flex: 5, child: _FinancialCard(data: d)),
              Expanded(flex: 7, child: _RecentRequestsCard(requests: d.recentRequests)),
            ],
          ),

          // Bottom section: Most depreciated equipment + Repair services summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              Expanded(
                flex: 6,
                child: _MostDepreciatedCard(equipments: d.mostDepreciatedEquipments),
              ),
              Expanded(
                flex: 6,
                child: _RepairServicesCard(services: d.repairServices),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── KPI Row ─────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.data});
  final _DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Equipamentos',
            value: data.equipmentCount.toString(),
            icon: Icons.fitness_center,
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: _KpiCard(
            label: 'Pedidos Abertos',
            value: data.openRequestsCount.toString(),
            icon: Icons.build_circle,
            color: Colors.orange,
          ),
        ),
        Expanded(
          child: _KpiCard(
            label: 'Serviços de Reparo',
            value: data.repairServicesCount.toString(),
            icon: Icons.handyman,
            color: Colors.green,
          ),
        ),
        Expanded(
          child: _KpiCard(
            label: 'Empresas de Manutenção',
            value: data.maintenanceCompaniesCount.toString(),
            icon: Icons.engineering,
            color: Colors.purple,
          ),
        ),
        Expanded(
          child: _KpiCard(
            label: 'Usuários',
            value: data.usersCount.toString(),
            icon: Icons.people,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Financial Card ───────────────────────────────────────────────────────────

class _FinancialCard extends StatelessWidget {
  const _FinancialCard({required this.data});
  final _DashboardData data;

  String _fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+,)'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    final pct = data.depreciationPercent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              'Patrimônio — Visão Financeira',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            _FinRow(label: 'Valor total de compra', value: _fmt(data.totalOriginalValue), color: Colors.blue),
            _FinRow(label: 'Valor atual total', value: _fmt(data.totalCurrentValue), color: Colors.green),
            _FinRow(label: 'Depreciação acumulada', value: _fmt(data.totalDepreciation), color: Colors.red),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Depreciação geral',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(pct * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _depreciationColor(pct),
                      ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.green.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(_depreciationColor(pct)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _depreciationColor(double pct) {
    if (pct < 0.3) return Colors.green;
    if (pct < 0.6) return Colors.orange;
    return Colors.red;
  }
}

class _FinRow extends StatelessWidget {
  const _FinRow({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ─── Recent Requests Card ─────────────────────────────────────────────────────

class _RecentRequestsCard extends StatelessWidget {
  const _RecentRequestsCard({required this.requests});
  final List<MaintenanceRequestModel> requests;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              'Pedidos Recentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Nenhum pedido encontrado')),
              )
            else
              ...requests.map((r) => _RequestTile(request: r)),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});
  final MaintenanceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final isOpen = request.closedAt == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen ? Colors.orange.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${request.requestNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isOpen ? Colors.orange : Colors.green,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  request.maintenanceDTO.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOpen ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOpen ? Colors.orange : Colors.green,
                width: 0.5,
              ),
            ),
            child: Text(
              isOpen ? 'Aberto' : 'Encerrado',
              style: TextStyle(
                fontSize: 11,
                color: isOpen ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Most Depreciated Equipment Card ─────────────────────────────────────────

class _MostDepreciatedCard extends StatelessWidget {
  const _MostDepreciatedCard({required this.equipments});
  final List<EquipmentModel> equipments;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              'Equipamentos com Maior Depreciação',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (equipments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Nenhum equipamento encontrado')),
              )
            else
              ...equipments.map((e) => _EquipmentDepreciationTile(equipment: e)),
          ],
        ),
      ),
    );
  }
}

class _EquipmentDepreciationTile extends StatelessWidget {
  const _EquipmentDepreciationTile({required this.equipment});
  final EquipmentModel equipment;

  @override
  Widget build(BuildContext context) {
    final lossAmt = equipment.originalValue - equipment.currentValue;
    final lossPct = equipment.originalValue > 0
        ? (lossAmt / equipment.originalValue).clamp(0.0, 1.0)
        : 0.0;
    final color = lossPct < 0.3
        ? Colors.green
        : lossPct < 0.6
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                equipment.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(lossPct * 100).toStringAsFixed(1)}% depreciado',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: lossPct,
                  minHeight: 6,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            Text(
              'R\$ ${equipment.currentValue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Repair Services Summary Card ─────────────────────────────────────────────

class _RepairServicesCard extends StatelessWidget {
  const _RepairServicesCard({required this.services});
  final List<RepairServiceModel> services;

  @override
  Widget build(BuildContext context) {
    final totalSubTotal = services.fold<double>(0, (s, r) => s + r.subTotal);
    final totalFinal = services.fold<double>(0, (s, r) => s + r.finalPrice);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              'Serviços de Reparo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (services.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('Nenhum serviço encontrado')),
              )
            else ...[
              // Summary totals
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  spacing: 8,
                  children: [
                    _SummaryRow(
                      label: 'Total de subtotais',
                      value: 'R\$ ${totalSubTotal.toStringAsFixed(2)}',
                    ),
                    _SummaryRow(
                      label: 'Total de valores finais',
                      value: 'R\$ ${totalFinal.toStringAsFixed(2)}',
                    ),
                    _SummaryRow(
                      label: 'Total de serviços',
                      value: services.length.toString(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Text(
                'Últimos serviços',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ...services.take(4).map((s) => _ServiceTile(service: s)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});
  final RepairServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            service.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'R\$ ${service.finalPrice.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
        ),
      ],
    );
  }
}
