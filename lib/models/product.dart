class Product {
  int? id;
  final String description;
  final String barcode;
  final double purchasePrice;
  final double salePrice;
  int quantity;
  DateTime lastPurchase;
  DateTime lastSale;

  Product({
    this.id,
    required this.description,
    required this.barcode,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.lastPurchase,
    required this.lastSale,
  });

  // Converte para Map (usado pelo SQFlite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'barcode': barcode,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'quantity': quantity,
      'lastPurchase': lastPurchase.toIso8601String(),
      'lastSale': lastSale.toIso8601String(),
    };
  }

  // Converte de Map (usado pelo SQFlite)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      description: map['description'],
      barcode: map['barcode'],
      purchasePrice: map['purchasePrice'],
      salePrice: map['salePrice'],
      quantity: map['quantity'],
      lastPurchase: DateTime.parse(map['lastPurchase']),
      lastSale: DateTime.parse(map['lastSale']),
    );
  }

  // Cópia do objeto (útil para atualizações)
  Product copyWith({
    int? id,
    String? description,
    String? barcode,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    DateTime? lastPurchase,
    DateTime? lastSale,
  }) {
    return Product(
      id: id ?? this.id,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      lastSale: lastSale ?? this.lastSale,
    );
  }
}