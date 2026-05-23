import 'dart:math';
import 'package:flutter/material.dart';

class OrbitPainter extends CustomPainter {
  final List<double> orbitRadii;
  final Color color;

  OrbitPainter({required this.orbitRadii, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (final radius in orbitRadii) {
      // Dashed orbit ring
      final circumference = 2 * pi * radius;
      const dashLength = 6.0;
      const gapLength = 8.0;
      final totalDash = dashLength + gapLength;
      final count = (circumference / totalDash).floor();

      for (int i = 0; i < count; i++) {
        final startAngle = (i * totalDash / circumference) * 2 * pi;
        final sweepAngle = (dashLength / circumference) * 2 * pi;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) => false;
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double opacity;

  ParticlePainter({required this.particles, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    for (final p in particles) {
      canvas.drawCircle(p, 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
