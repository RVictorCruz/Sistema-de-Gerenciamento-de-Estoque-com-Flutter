import 'package:controle_total/screens/report_screen.dart';
import 'package:controle_total/screens/sale_report.dart';
import 'package:flutter/material.dart';
import 'package:controle_total/screens/home_screen.dart';

void main() {
  runApp(const StockScanApp());
}

class StockScanApp extends StatelessWidget {
  const StockScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Total',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      initialRoute: '/', // Defina a rota inicial
      routes: {
        '/': (context) => const HomeScreen(), // Rota inicial
        '/home': (context) => const HomeScreen(),
        '/report': (context) => const ReportScreen(), // Alias para a home
        // Outras rotas que você precisar
        '/saleReport': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SaleReportScreen(
            sale: args['sale'],
            items: args['items'],
          );
        },
      },
      // Rota para erros 404
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Página não encontrada')),
          body: const Center(child: Text('Esta página não existe!')),
        ),
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.light,
        primary: const Color(0xFF2E7D32),
        secondary: const Color(0xFF6A1B9A),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 2,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      useMaterial3: true,
    );
  }
}
