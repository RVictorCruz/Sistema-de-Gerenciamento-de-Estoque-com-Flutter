import 'package:flutter/material.dart';

class BarcodeScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double cutOutSize;

  const BarcodeScannerOverlay({
    super.key,
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.borderLength = 30.0,
    this.cutOutSize = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

        return Stack(
          children: [
            // Fundo semi-transparente
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha((0.8 * 255).round()),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: cutOutSize,
                      height: cutOutSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bordas do scanner
            Center(
              child: SizedBox(
                width: cutOutSize,
                height: cutOutSize,
                child: CustomPaint(
                  painter: _ScannerBorderPainter(
                    borderPaint: borderPaint,
                    borderLength: borderLength,
                  ),
                ),
              ),
            ),
            // Texto de instrução
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Posicione o código de barras na área de leitura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerBorderPainter extends CustomPainter {
  final Paint borderPaint;
  final double borderLength;

  _ScannerBorderPainter({
    required this.borderPaint,
    required this.borderLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, borderLength)
      ..lineTo(0, 0)
      ..lineTo(borderLength, 0)
      ..moveTo(size.width - borderLength, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, borderLength)
      ..moveTo(size.width, size.height - borderLength)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width - borderLength, size.height)
      ..moveTo(borderLength, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}