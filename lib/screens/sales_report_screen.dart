import 'package:flutter/material.dart';
import 'package:controle_total/database/db_helper.dart';
import 'package:controle_total/models/sale.dart';
import 'package:controle_total/models/sale_item.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  late Future<List<Sale>> _salesFuture;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() {
      _salesFuture = DatabaseHelper.instance.getAllSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Vendas', style: TextStyle(color: Color.fromARGB(255, 119, 119, 119)),),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
          ),
        ],
      ),
      body: FutureBuilder<List<Sale>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma venda registrada'));
          }

          final sales = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSalesSummary(sales),
                  const SizedBox(height: 20),
                  ...sales.map((sale) => _buildSaleCard(sale)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

 Widget _buildSalesSummary(List<Sale> sales) {
  final totalSales = sales.length;
  final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + (sale.totalAmount));
  
  final last30DaysRevenue = sales.fold<double>(0, (sum, sale) {
    try {
      final saleDate = DateTime.tryParse(sale.saleDate.timeZoneName);
      if (saleDate == null) return sum;
      
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      if (saleDate.isAfter(thirtyDaysAgo)) {
        return sum + (sale.totalAmount);
      }
    } catch (e) {
      debugPrint('Erro ao processar data da venda: $e');
    }
    return sum;
  });

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Resumo de Vendas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total de Vendas', totalSales.toString()),
              _buildSummaryItem('Receita Total', _currencyFormat.format(totalRevenue)),
              _buildSummaryItem('Últimos 30 dias', _currencyFormat.format(last30DaysRevenue)),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

 Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          'Venda #${sale.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_formatSaleDate(sale.saleDate)), // Método corrigido
        trailing: Text(
          _currencyFormat.format(sale.totalAmount),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        children: [
          FutureBuilder<List<SaleItem>>(
            future: DatabaseHelper.instance.getSaleItems(sale.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              
              if (snapshot.hasError || !snapshot.hasData) {
                return const ListTile(
                  title: Text('Erro ao carregar itens'),
                );
              }

              final items = snapshot.data!;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: items.map((item) => _buildSaleItem(item)).toList(),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Informações da Venda'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendedor: ${sale.sellerName}'),
                        Text('Empresa: ${sale.companyName}'),
                        Text('CNPJ: ${sale.cnpj}'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

String _formatSaleDate(DateTime date) {
  try {
    return _dateFormat.format(date);
  } catch (e) {
    debugPrint('Erro ao formatar data: $e');
    return date.toString();
  }
}

  Widget _buildSaleItem(SaleItem item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        '${item.quantity}x',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      title: Text(item.description),
      trailing: Text(
        _currencyFormat.format(item.totalPrice),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}