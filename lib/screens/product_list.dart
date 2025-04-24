import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import 'product_form.dart';
import 'sale_screen.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();

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
        title: const Text('Lista de Produtos'),
        backgroundColor: const Color.fromARGB(162, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 61, 131, 252),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToProductForm(),
            tooltip: 'Adicionar novo produto',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar produtos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshProducts();
                  },
                ),
              ),
              onChanged: (value) => _refreshProducts(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum produto cadastrado'));
                } else {
                  return _buildProductList(snapshot.data!);
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _navigateToProductForm(),
        tooltip: 'Adicionar produto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    final filteredProducts = products.where((product) {
      final searchTerm = _searchController.text.toLowerCase();
      return product.description.toLowerCase().contains(searchTerm) ||
          product.barcode.contains(searchTerm);
    }).toList();

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return ProductCard(
            product: product,
            onTap: () => _showProductDetails(context, product),
            onSell: () => _startSaleFromList(context, product),
            onEdit: () => _navigateToProductForm(product: product),
            onDelete: () => _confirmDeleteProduct(context, product),
          );
        },
      ),
    );
  }

  Future<void> _startSaleFromList(BuildContext context, Product product) async {
    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleScreen(product: product),
      ),
    );

    if (result == true) {
      _refreshProducts();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Venda de ${product.description} registrada!')),
        );
      }
    }
  }

  Future<void> _navigateToProductForm({Product? product}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductForm(product: product),
      ),
    );

    if (result != null) {
      _refreshProducts();
    }
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.description),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código: ${product.barcode}'),
              const SizedBox(height: 8),
              Text('Preço compra: R\$${product.purchasePrice.toStringAsFixed(2)}'),
              Text('Preço venda: R\$${product.salePrice.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Estoque: ${product.quantity}'),
              const SizedBox(height: 8),
              Text('Última compra: ${_formatDate(product.lastPurchase)}'),
              Text('Última venda: ${_formatDate(product.lastSale)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProduct(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Excluir "${product.description}" permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deleteProduct(product.id!);
        if (!mounted) return;
        
        if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.description} excluído com sucesso')),
            );
          }
        _refreshProducts();
      } catch (e) {
        if (!mounted) return;
        if (context.mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro ao excluir: $e')),
  );
}
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}