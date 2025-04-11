import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import 'sale_report.dart';
import 'product_list.dart';

class SaleScreen extends StatefulWidget {
  final Product product;

  const SaleScreen({super.key, required this.product});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _sellerNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final List<SaleItem> _saleItems = [];
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _addProduct(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _showProductsList(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Vendedor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Empresa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cnpjController,
                    decoration: const InputDecoration(
                      labelText: 'CNPJ/CPF',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Itens da Venda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._saleItems.map((item) => _buildSaleItemCard(item)),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Text(
            'Total: R\$${_totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Finalizar'),
                  onPressed: () => _finalizeSale(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleItemCard(SaleItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(item.description),
        subtitle: Text('R\$${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () => _updateItemQuantity(item, -1),
            ),
            Text(item.quantity.toString()),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _updateItemQuantity(item, 1),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeItem(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProductsList(BuildContext context) async {
    final selectedProduct = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListScreen(),
      ),
    );

    if (selectedProduct != null && mounted) {
      _addProduct(selectedProduct);
    }
  }

  void _addProduct(Product product, [int quantity = 1]) {
    setState(() {
      final existingIndex = _saleItems.indexWhere((item) => item.productId == product.id);

      if (existingIndex >= 0) {
        _saleItems[existingIndex] = _saleItems[existingIndex].copyWith(
          quantity: _saleItems[existingIndex].quantity + quantity,
          totalPrice: _saleItems[existingIndex].unitPrice * (_saleItems[existingIndex].quantity + quantity),
        );
      } else {
        _saleItems.add(SaleItem(
          productId: product.id!,
          saleId: 0, // Será atualizado ao finalizar
          description: product.description,
          quantity: quantity,
          unitPrice: product.salePrice,
          totalPrice: product.salePrice * quantity,
        ));
      }

      _calculateTotal();
    });
  }

  void _updateItemQuantity(SaleItem item, int change) {
    final newQuantity = item.quantity + change;
    if (newQuantity > 0) {
      setState(() {
        _saleItems[_saleItems.indexOf(item)] = item.copyWith(
          quantity: newQuantity,
          totalPrice: item.unitPrice * newQuantity,
        );
        _calculateTotal();
      });
    }
  }

  void _removeItem(SaleItem item) {
    setState(() {
      _saleItems.remove(item);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _totalAmount = _saleItems.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  Future<void> _finalizeSale(BuildContext context) async {
    if (_sellerNameController.text.isEmpty ||
        _companyNameController.text.isEmpty ||
        _cnpjController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (_saleItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione itens à venda')),
      );
      return;
    }

    try {
      final sale = Sale(
        sellerName: _sellerNameController.text,
        companyName: _companyNameController.text,
        cnpj: _cnpjController.text,
        saleDate: DateTime.now(),
        totalAmount: _totalAmount,
      );

      // 1. Atualiza o banco de dados
      await DatabaseHelper.instance.executeSaleWithItems(sale, _saleItems);

      if (!mounted) return; // Verificação se o State está montado

      // 2. Navega para a tela do PDF
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SaleReportScreen(
            sale: sale,
            items: _saleItems,
          ),
        ),
      );

      // 3. Volta para a tela inicial
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao finalizar venda: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sellerNameController.dispose();
    _companyNameController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }
}

extension SaleItemCopyWith on SaleItem {
  SaleItem copyWith({
    int? saleId,
    int? quantity,
    double? totalPrice,
  }) {
    return SaleItem(
      id: id,
      saleId: saleId ?? this.saleId,
      productId: productId,
      description: description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
