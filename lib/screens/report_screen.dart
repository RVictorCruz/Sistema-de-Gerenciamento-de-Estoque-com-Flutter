import 'package:flutter/material.dart';
import 'package:controle_total/models/product.dart';
import 'package:controle_total/database/db_helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});


  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = DatabaseHelper.instance.getAllProducts();
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      shadowColor: Colors.black,
      surfaceTintColor: const Color.fromARGB(255, 255, 0, 0),
      title: const Text('Relatório de Estoque', style: TextStyle(color: Color.fromARGB(255, 119, 119, 119)),),
    ),
    body: FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum produto cadastrado'));
        }
        
        final products = snapshot.data!;
        return SingleChildScrollView(
  child: AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: Column(
    children: [
      _buildInventorySummary(products),
      SizedBox(
        height: 400,
        child: _buildProductsChart(products),
      ),
      _buildProductsTable(products), // Remove o Expanded
      const SizedBox(height: 20), // Espaço extra no final
    ],
  ),)
);
      },
    ),
  );
}

Widget _buildProductsTable(List<Product> products) {
  // Ordena por quantidade (do maior para o menor)
  products.sort((a, b) => b.quantity.compareTo(a.quantity));

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columnSpacing: 20,
      horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('Produto', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Text('Estoque', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
        ),
        DataColumn(
          label: Text('Preço', style: TextStyle(fontWeight: FontWeight.bold)),
          numeric: true,
        ),
        DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: products.map((product) {
        final isLowStock = product.quantity <= 5;
        return DataRow(cells: [
          DataCell(Text(product.description)),
          DataCell(
            Text(
              product.quantity.toString(),
              style: TextStyle(
                color: isLowStock ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(Text('R\$${product.salePrice.toStringAsFixed(2)}')),
          DataCell(Text(product.barcode)),
        ]);
      }).toList(),
    ),
  );
}

Widget _buildProductsChart(List<Product> products) {
  // Ordena e filtra produtos como antes
  products.sort((a, b) => b.quantity.compareTo(a.quantity));
  final displayedProducts = products.take(5).toList();

  return Container(
    height: 300, // Altura fixa para o gráfico
    padding: const EdgeInsets.all(16),
    child: SfCircularChart(
      margin: EdgeInsets.zero, // Remove margens internas
      title: ChartTitle(text: 'Distribuição do Estoque', textStyle: TextStyle(fontWeight: FontWeight.bold)),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      series: <PieSeries<Product, String>>[
        PieSeries<Product, String>(
          dataSource: displayedProducts,
          xValueMapper: (Product product, _) => product.description,
          yValueMapper: (Product product, _) => product.quantity,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            showZeroValue: true,
            textStyle: const TextStyle(fontSize: 12),
            connectorLineSettings: const ConnectorLineSettings(
              length: '15%',
              width: 2,
            ),
            // Mostra tanto o nome quanto o valor
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              return Text('${data.description}\n${data.quantity}');
            },
          ),
          radius: '70%', // Controla o tamanho do raio do gráfico
          explode: true,
        )
      ],
    ),
  );
}

 Widget _buildInventorySummary(List<Product> products) {
  final totalItems = products.fold<int>(0, (sum, p) => sum + p.quantity);
  final totalValue = products.fold<double>(0, (sum, p) => sum + (p.quantity * p.salePrice));
  final lowStockItems = products.where((p) => p.quantity <= 5).length;

  return Card(
    margin: const EdgeInsets.all(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                title: 'Itens no Estoque',
                value: totalItems.toString(),
                icon: Icons.inventory_2,
                color: Colors.blue,
              ),
              _buildSummaryItem(
                title: 'Valor Total',
                value: 'R\$${totalValue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              _buildSummaryItem(
                title: 'Itens Críticos',
                value: lowStockItems.toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: products.where((p) => p.quantity <= 5).length / products.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          const SizedBox(height: 4),
          Text(
            '${(products.where((p) => p.quantity <= 5).length / products.length * 100).toStringAsFixed(1)}% do estoque precisa de reposição',
            style: const TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSummaryItem({required String title, required String value, required IconData icon, required Color color}) {
  return Column(
    children: [
      Icon(icon, size: 30, color: color),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 12)),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ],
  );
}
}