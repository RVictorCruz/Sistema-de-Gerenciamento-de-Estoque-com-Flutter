import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import 'product_form.dart';
import 'sale_screen.dart';
import '../widgets/barcode_scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  Product? scannedProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Produto'),
        shadowColor: Colors.black,
        foregroundColor: Colors.blue,
        backgroundColor: const Color.fromARGB(255, 42, 43, 43),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off: return const Icon(Icons.flash_off);
                  case TorchState.on: return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductForm(),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcodeDetected,
          ),
          const BarcodeScannerOverlay(),
        ],
      ),
    );
  }

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    final product = await DatabaseHelper.instance.getProductByBarcode(barcode);
    
    if (!mounted) return;

    setState(() => scannedProduct = product);
    
    if (product != null) {
      cameraController.stop();
      _showProductDialog(context, product);
    } else {
      _showAddProductDialog(context, barcode);
    }
  }

  void _showProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.description),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Código: ${product.barcode}'),
            Text('Preço: R\$${product.salePrice.toStringAsFixed(2)}'),
            Text('Estoque: ${product.quantity}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => SaleScreen(product: product),
                ),
              );
              
              // Atualiza a tela se a venda foi concluída
              if (result == true && mounted) {
                _refreshProduct(product);
              }
            },
            child: const Text('Vender'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductForm(product: product),
                ),
              );
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshProduct(Product product) async {
    final updatedProduct = await DatabaseHelper.instance.getProductByBarcode(product.barcode);
    if (updatedProduct != null && mounted) {
      setState(() {
        scannedProduct = updatedProduct;
      });
    }
  }

  void _showAddProductDialog(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Produto não encontrado'),
        content: Text('Deseja cadastrar o produto com código $barcode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductForm(
                    product: Product(
                      description: '',
                      barcode: barcode,
                      purchasePrice: 0,
                      salePrice: 0,
                      quantity: 0,
                      lastPurchase: DateTime.now(),
                      lastSale: DateTime.now(),
                    ),
                  ),
                ),
              );
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}