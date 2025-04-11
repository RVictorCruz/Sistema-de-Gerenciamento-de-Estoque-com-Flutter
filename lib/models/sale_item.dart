import '../models/models.dart';
class SaleItem {
  int? id;
  final int? saleId;
  final int productId;
  final String description;
  int quantity;
  final double unitPrice;
  double totalPrice;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'productId': productId,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['saleId'],
      productId: map['productId'],
      description: map['description'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'],
      totalPrice: map['totalPrice'],
    );
  }

  // Método para criar itens a partir de um Product
  factory SaleItem.fromProduct({
    required int saleId,
    required Product product,
    int quantity = 1,
  }) {
    return SaleItem(
      saleId: saleId,
      productId: product.id!,
      description: product.description,
      quantity: quantity,
      unitPrice: product.salePrice,
      totalPrice: product.salePrice * quantity,
    );
  }
}