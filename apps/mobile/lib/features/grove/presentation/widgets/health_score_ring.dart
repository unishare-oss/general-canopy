import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:canopy/features/grove/domain/entities/adopted_sapling.dart';

class HealthScoreRing extends StatelessWidget {
  const HealthScoreRing({super.key, required this.score, this.size = 56});

  final int score;
  final double size;

  static Color colorForStatus(HealthStatus status, ColorScheme cs) =>
      switch (status) {
        HealthStatus.excellent => const Color(0xFF4CAF50),
        HealthStatus.good => const Color(0xFF8BC34A),
        HealthStatus.attention => const Color(0xFFFFC107),
        HealthStatus.critical => cs.error,
      };

  HealthStatus get _status {
    if (score >= 90) return HealthStatus.excellent;
    if (score >= 70) return HealthStatus.good;
    if (score >= 50) return HealthStatus.attention;
    return HealthStatus.critical;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = colorForStatus(_status, cs);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              score: score,
              color: color,
              trackColor: cs.surfaceContainerHighest,
              strokeWidth: size * 0.1,
            ),
          ),
          Text(
            '$score',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final int score;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (score / 100);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.score != score || old.color != color;
}
