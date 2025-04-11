class Sale {
  int? id;
  final String sellerName;
  final String companyName;
  final String cnpj;
  final DateTime saleDate;
  final double totalAmount;

  Sale({
    this.id,
    required this.sellerName,
    required this.companyName,
    required this.cnpj,
    required this.saleDate,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerName': sellerName,
      'companyName': companyName,
      'cnpj': cnpj,
      'saleDate': saleDate.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      sellerName: map['sellerName'],
      companyName: map['companyName'],
      cnpj: map['cnpj'],
      saleDate: DateTime.parse(map['saleDate']),
      totalAmount: map['totalAmount'],
    );
  }
}