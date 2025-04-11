import 'package:controle_total/models/product.dart';
import 'package:controle_total/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard Widget Tests', () {
    final product = Product(
      id: 1,
      description: 'Produto de Teste',
      barcode: '123456789',
      purchasePrice: 10.00,
      salePrice: 19.99,
      quantity: 5,
      lastPurchase: DateTime(2025, 4, 10),
      lastSale: DateTime(2025, 4, 9),
    );

    testWidgets('renders product information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(product: product),
      ));

      // Verifica se a descrição do produto é exibida
      expect(find.text('Produto de Teste'), findsOneWidget);

      // Verifica se o código de barras é exibido
      expect(find.text('Código: 123456789'), findsOneWidget);

      // Verifica se o preço de venda é exibido formatado
      expect(find.text('Preço: R\$19.99'), findsOneWidget);

      // Verifica se o estoque é exibido
      expect(find.text('Estoque: 5'), findsOneWidget);

      // Verifica se o Chip de estoque tem a cor correta (verde para estoque > 0)
      final chipFinder = find.byType(Chip);
      expect(chipFinder, findsOneWidget);
      final chipWidget = tester.widget<Chip>(chipFinder);
      expect(chipWidget.backgroundColor, Colors.green);
    });

    testWidgets('renders out of stock correctly', (WidgetTester tester) async {
      final outOfStockProduct = product.copyWith(quantity: 0);
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(product: outOfStockProduct),
      ));

      // Verifica se o texto de estoque é exibido
      expect(find.text('Estoque: 0'), findsOneWidget);

      // Verifica se o Chip de estoque tem a cor correta (vermelho para estoque = 0)
      final chipFinder = find.byType(Chip);
      expect(chipFinder, findsOneWidget);
      final chipWidget = tester.widget<Chip>(chipFinder);
      expect(chipWidget.backgroundColor, Colors.red);
    });

    testWidgets('calls onTap callback when card is tapped', (WidgetTester tester) async {
      bool onTapCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onTap: () {
            onTapCalled = true;
          },
        ),
      ));

      // Toca no InkWell (que cobre o Card)
      await tester.tap(find.byType(InkWell));
      expect(onTapCalled, isTrue);
    });

    testWidgets('calls onSell callback when sell button is tapped', (WidgetTester tester) async {
      bool onSellCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onSell: () {
            onSellCalled = true;
          },
        ),
      ));

      // Encontra e toca no IconButton de vender
      await tester.tap(find.byIcon(Icons.shopping_cart));
      expect(onSellCalled, isTrue);
    });

    testWidgets('calls onEdit callback when edit menu item is selected', (WidgetTester tester) async {
      bool onEditCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onEdit: () {
            onEditCalled = true;
          },
        ),
      ));

      // Abre o PopupMenuButton
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(); // Aguarda a animação do menu

      // Seleciona o item 'Editar'
      await tester.tap(find.text('Editar'));
      expect(onEditCalled, isTrue);
    });

    testWidgets('calls onDelete callback when delete menu item is selected', (WidgetTester tester) async {
      bool onDeleteCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onDelete: () {
            onDeleteCalled = true;
          },
        ),
      ));

      // Abre o PopupMenuButton
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle(); // Aguarda a animação do menu

      // Seleciona o item 'Excluir'
      await tester.tap(find.text('Excluir'));
      expect(onDeleteCalled, isTrue);
    });

    testWidgets('does not show sell button when onSell is null', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(product: product),
      ));

      expect(find.byIcon(Icons.shopping_cart), findsNothing);
    });

    testWidgets('does not show edit menu item when onEdit is null', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onDelete: () {},
        ),
      ));

      // Abre o PopupMenuButton
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Editar'), findsNothing);
    });

    testWidgets('does not show delete menu item when onDelete is null', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(
          product: product,
          onEdit: () {},
        ),
      ));

      // Abre o PopupMenuButton
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Excluir'), findsNothing);
    });

    testWidgets('description text overflows correctly', (WidgetTester tester) async {
      const longDescription = 'Este é um produto com uma descrição muito, muito, muito, muito, muito, muito, muito, muito, muito longa para testar o overflow de texto.';
      final longProduct = product.copyWith(description: longDescription);
      await tester.pumpWidget(MaterialApp(
        home: ProductCard(product: longProduct),
      ));

      final textFinder = find.textContaining(longDescription.substring(0, 20)); // Verifica parte do texto
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}