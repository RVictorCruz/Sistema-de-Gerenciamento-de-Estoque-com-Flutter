import 'package:flutter/material.dart';
import '../models/sale_item.dart';

class SaleItemCard extends StatelessWidget {
  final SaleItem item;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;

  const SaleItemCard({
    super.key,
    required this.item,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$${item.unitPrice.toStringAsFixed(2)} × ${item.quantity}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              'R\$${item.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (onIncrease != null || onDecrease != null || onRemove != null)
              Row(
                children: [
                  if (onDecrease != null)
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: onDecrease,
                    ),
                  if (onIncrease != null)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: onIncrease,
                    ),
                  if (onRemove != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onRemove,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}