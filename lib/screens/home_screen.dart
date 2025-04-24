import 'package:flutter/material.dart';
import 'package:controle_total/screens/report_screen.dart';
import 'package:controle_total/screens/sales_report_screen.dart';
import 'package:controle_total/screens/product_list.dart';
import 'package:controle_total/screens/scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 254, 255),
      appBar: AppBar(
        title: const Text(
          'Controle Total',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Imagem no topo
              Container(
                height: 250,
                width: 400,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 5, color: Colors.white12, style: BorderStyle.solid),
                  image: const DecorationImage(
                    image: AssetImage('lib/assets/images/logo.jpg'), // Substitua pelo seu asset
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Linha com 2 cards superiores
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      icon: Icons.qr_code_scanner,
                      title: 'Escanear Código',
                      onTap: () => _navigateTo(context, const ScannerScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      icon: Icons.list_alt,
                      title: 'Lista de Produtos',
                      onTap: () => _navigateTo(context, const ProductListScreen()),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Linha com 2 cards inferiores
              Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      icon: Icons.analytics,
                      title: 'Relatório de Produtos',
                      onTap: () => _navigateTo(context, const ReportScreen()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Relatório de Vendas',
                      onTap: () => _navigateTo(context, const SalesReportScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 66, 142, 255),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 5, color: Colors.white12, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withAlpha(100),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF52D0F4).withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}