import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SaleReportScreen extends StatelessWidget {
  final Sale sale;
  final List<SaleItem> items;

  const SaleReportScreen({
    super.key,
    required this.sale,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota Fiscal'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(format, sale, items),
              canChangePageFormat: false,
              canChangeOrientation: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Voltar ao Início'),
                onPressed: () => _navigateHome(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }

  Future<Uint8List> _generatePdf(
    PdfPageFormat format,
    Sale sale,
    List<SaleItem> items,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    final tableData = [
      ['Descrição', 'Qtd', 'Unitário', 'Total'],
      ...items.map((item) => [
            item.description,
            item.quantity.toString(),
            'R\$ ${item.unitPrice.toStringAsFixed(2)}',
            'R\$ ${item.totalPrice.toStringAsFixed(2)}',
          ]),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'NOTA FISCAL',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Empresa: ${sale.companyName}', style: pw.TextStyle(font: font)),
              pw.Text('CNPJ: ${sale.cnpj}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 10),
              pw.Text('Vendedor: ${sale.sellerName}', style: pw.TextStyle(font: font)),
              pw.Text('Data: ${_formatDate(sale.saleDate)}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'ITENS VENDIDOS',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                data: tableData,
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: font,
                ),
                cellStyle: pw.TextStyle(font: font),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
              ),
              pw.SizedBox(height: 30),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: R\$ ${sale.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: font,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }
}