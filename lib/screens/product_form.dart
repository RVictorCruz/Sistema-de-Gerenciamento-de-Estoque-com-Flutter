import 'package:controle_total/database/db_helper.dart';
import 'package:controle_total/models/product.dart';
import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Product? product; // Agora recebe um Product opcional

  const ProductForm({super.key, this.product});
  
  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController(); // Novo controller para código de barras
  final _purchasePriceController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estiver editando
    if (widget.product != null) {
      _descriptionController.text = widget.product!.description;
      _barcodeController.text = widget.product!.barcode;
      _purchasePriceController.text = widget.product!.purchasePrice.toString();
      _quantityController.text = widget.product!.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo para código de barras
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Barras',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text, // Teclado padrão para texto
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um código';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _purchasePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço de Compra',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true), // Teclado numérico com decimal
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um preço';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor, insira um valor válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade em Estoque',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number, // Teclado numérico simples
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a quantidade';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor, insira um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Salvar Produto', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id,
        description: _descriptionController.text,
        barcode: _barcodeController.text, // Usa o código digitado
        purchasePrice: double.parse(_purchasePriceController.text),
        salePrice: double.parse(_purchasePriceController.text) * 1.4,
        quantity: int.parse(_quantityController.text),
        lastPurchase: DateTime.now(),
        lastSale: DateTime.now(),
      );

      try {
        if (widget.product == null) {
          await DatabaseHelper.instance.insertProduct(product);
        } else {
          await DatabaseHelper.instance.updateProduct(product);
        }

        if (!mounted) return;
        Navigator.pop(context, product);
      } catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erro'),
            content: Text(e.toString().contains('UNIQUE constraint')
                ? 'Já existe um produto com este código de barras'
                : 'Erro ao salvar: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _barcodeController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}