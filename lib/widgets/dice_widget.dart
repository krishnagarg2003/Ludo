import 'package:flutter/material.dart';

class DiceWidget extends StatelessWidget {
  final int value;
  final Color color;
  final bool isRolling;

  const DiceWidget({
    super.key,
    required this.value,
    required this.color,
    this.isRolling = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F0F0)],
        ),
      ),
      child: isRolling
          ? Center(child: CircularProgressIndicator(color: color, strokeWidth: 3))
          : CustomPaint(
              painter: DicePainter(value, color),
            ),
    );
  }
}

class DicePainter extends CustomPainter {
  final int value;
  final Color color;

  DicePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double padding = size.width * 0.2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double dotRadius = size.width * 0.08;

    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }

    if (value == 1 || value == 3 || value == 5) {
      drawDot(centerX, centerY);
    }
    if (value >= 2) {
      drawDot(padding, padding);
      drawDot(size.width - padding, size.height - padding);
    }
    if (value >= 4) {
      drawDot(size.width - padding, padding);
      drawDot(padding, size.height - padding);
    }
    if (value == 6) {
      drawDot(padding, centerY);
      drawDot(size.width - padding, centerY);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
