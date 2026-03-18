import 'package:flutter/material.dart';
import 'package:tcc_gym_management_web_v1_flutter/backend/models/user_model.dart';

typedef OnRefresh = Future<void> Function();

typedef RowBuilder<T> = DataRow Function(T item);

class GenericDataTable<T> extends StatelessWidget {
  const GenericDataTable({
    super.key,
    required this.title,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.onRefresh,
    required this.isLoading,
    this.emptyMessage = 'Nenhum registro encontrado.',
  });

  final String title;
  final List<T> items;
  final List<DataColumn> columns;
  final RowBuilder<T> rowBuilder;
  final OnRefresh onRefresh;
  final bool isLoading;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Atualizar'),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(emptyMessage),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    columns: columns,
                    rows: items.map(rowBuilder).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UserTable extends GenericDataTable<UserModel> {
  UserTable({
    super.key,
    required super.items,
    required super.onRefresh,
    required super.isLoading,
    required Future<void> Function(UserModel user) onEdit,
    required Future<void> Function(UserModel user) onDelete,
    super.emptyMessage,
  }) : super(
         title: 'Usuários',
         columns: const [
           DataColumn(
             label: Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
           ),
           DataColumn(
             label: Text("Nome", style: TextStyle(fontWeight: FontWeight.bold)),
           ),
           DataColumn(
             label: Text(
               "Email",
               style: TextStyle(fontWeight: FontWeight.bold),
             ),
           ),
           DataColumn(
             label: Text(
               "Ações",
               style: TextStyle(fontWeight: FontWeight.bold),
             ),
           ),
         ],
         rowBuilder: (user) {
           return DataRow(
             cells: [
               DataCell(Text(user.id)),
               DataCell(Text(user.name)),
               DataCell(Text(user.email)),
               DataCell(
                 Row(
                   spacing: 8,
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     ElevatedButton(
                       onPressed: () => onEdit(user),
                       child: const Text('Editar'),
                     ),
                     ElevatedButton(
                       onPressed: () => onDelete(user),

                       child: const Text('Excluir'),
                     ),
                   ],
                 ),
               ),
             ],
           );
         },
       );
}
