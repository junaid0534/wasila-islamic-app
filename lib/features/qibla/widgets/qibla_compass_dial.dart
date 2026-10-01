import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class QiblaCompassDial extends StatelessWidget {
  final double heading; // Current phone heading (0-360)
  final double qiblaAngle; // Kaaba angle from North (0-360)
  final bool isAligned; // Within +/- 3 degrees
  final double size;

  const QiblaCompassDial({
    super.key,
    required this.heading,
    required this.qiblaAngle,
    required this.isAligned,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    // Relative angle between current heading and Qibla
    final angleDiff = (qiblaAngle - heading + 360) % 360;
    final normalizedDiff = angleDiff > 180 ? angleDiff - 360 : angleDiff;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer alignment glow effect when facing Kaaba
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isAligned
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.45),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
            ),

            // Rotating Compass Disc (rotates opposite to phone heading)
            Transform.rotate(
              angle: -heading * (math.pi / 180.0),
              child: CustomPaint(
                size: Size(size, size),
                painter: _CompassDiscPainter(
                  qiblaAngle: qiblaAngle,
                  isAligned: isAligned,
                ),
              ),
            ),

            // Fixed Top Device Sight Needle (Points straight ahead)
            Positioned(
              top: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomPaint(
                    size: const Size(20, 16),
                    painter: _TopPointerPainter(
                      color: isAligned ? const Color(0xFFFFD54F) : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Center Info Hub
            Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isAligned
                      ? [
                          const Color(0xFF1E6050),
                          const Color(0xFF14473B),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF6FAF8),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isAligned ? const Color(0xFFFFD54F) : AppColors.sageBorder,
                  width: isAligned ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                    color: isAligned ? const Color(0xFFFFD54F) : AppColors.primary,
                    size: 26,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${heading.toStringAsFixed(0)}°',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isAligned ? Colors.white : AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    isAligned
                        ? 'ALIGNED'
                        : '${normalizedDiff > 0 ? "+" : ""}${normalizedDiff.toStringAsFixed(0)}°',
                    style: GoogleFonts.poppins(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isAligned
                          ? const Color(0xFFFFD54F)
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the rotating compass face, ticks, cardinal letters, and Kaaba marker
class _CompassDiscPainter extends CustomPainter {
  final double qiblaAngle;
  final bool isAligned;

  _CompassDiscPainter({
    required this.qiblaAngle,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Compass Outer Base Background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          const Color(0xFFF2F7F5),
          const Color(0xFFE3EDE8),
        ],
        stops: const [0.65, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 4, bgPaint);

    // 2. Outer Ring Border
    final ringPaint = Paint()
      ..color = isAligned ? const Color(0xFFFFD54F) : const Color(0xFFB8D5CB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 2.5 : 1.5;
    canvas.drawCircle(center, radius - 4, ringPaint);

    // 3. Inner Decorative Track
    final trackPaint = Paint()
      ..color = AppColors.sageBorder.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 24, trackPaint);

    // 4. Degree Ticks & Numbers
    final tickPaint = Paint()..strokeCap = StrokeCap.round;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * (math.pi / 180.0) - (math.pi / 2.0); // 0° is North (top)
      final bool isMajor = deg % 30 == 0;
      final bool isCardinal = deg % 90 == 0;

      final double tickLength = isCardinal ? 14 : (isMajor ? 10 : 5);
      final double strokeWidth = isCardinal ? 2.2 : (isMajor ? 1.5 : 0.8);
      final Color tickColor = isCardinal
          ? (deg == 0 ? const Color(0xFFD32F2F) : AppColors.primary)
          : (isMajor ? AppColors.primaryDark.withValues(alpha: 0.6) : AppColors.textMuted.withValues(alpha: 0.35));

      tickPaint
        ..color = tickColor
        ..strokeWidth = strokeWidth;

      final startOffset = Offset(
        center.dx + (radius - 8) * math.cos(rad),
        center.dy + (radius - 8) * math.sin(rad),
      );
      final endOffset = Offset(
        center.dx + (radius - 8 - tickLength) * math.cos(rad),
        center.dy + (radius - 8 - tickLength) * math.sin(rad),
      );

      canvas.drawLine(startOffset, endOffset, tickPaint);

      // Draw Cardinal Direction Labels (N, E, S, W)
      if (isCardinal) {
        final label = deg == 0
            ? 'N'
            : (deg == 90 ? 'E' : (deg == 180 ? 'S' : 'W'));
        final textSpan = TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? const Color(0xFFD32F2F) : AppColors.primaryDark,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            fontFamily: 'sans-serif',
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final labelRadius = radius - 36;
        final labelOffset = Offset(
          center.dx + labelRadius * math.cos(rad) - (tp.width / 2),
          center.dy + labelRadius * math.sin(rad) - (tp.height / 2),
        );
        tp.paint(canvas, labelOffset);
      }
    }

    // 5. Draw Kaaba Direction Ray & Marker
    _drawKaabaMarker(canvas, center, radius);
  }

  void _drawKaabaMarker(Canvas canvas, Offset center, double radius) {
    // Qibla angle relative to North (0° = Top / -pi/2)
    final qiblaRad = (qiblaAngle * (math.pi / 180.0)) - (math.pi / 2.0);

    // Glowing line pointing from center towards Kaaba
    final beamPaint = Paint()
      ..color = const Color(0xFFFFB300).withValues(alpha: isAligned ? 0.9 : 0.6)
      ..strokeWidth = isAligned ? 3.0 : 2.0
      ..strokeCap = StrokeCap.round;

    final beamStart = Offset(
      center.dx + (radius * 0.42) * math.cos(qiblaRad),
      center.dy + (radius * 0.42) * math.sin(qiblaRad),
    );
    final beamEnd = Offset(
      center.dx + (radius - 32) * math.cos(qiblaRad),
      center.dy + (radius - 32) * math.sin(qiblaRad),
    );

    canvas.drawLine(beamStart, beamEnd, beamPaint);

    // Kaaba Marker Position near outer rim
    final kaabaCenter = Offset(
      center.dx + (radius - 18) * math.cos(qiblaRad),
      center.dy + (radius - 18) * math.sin(qiblaRad),
    );

    // Kaaba background golden glow badge
    final kaabaBgPaint = Paint()
      ..color = const Color(0xFF14473B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(kaabaCenter, 13, kaabaBgPaint);

    final kaabaBorderPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(kaabaCenter, 13, kaabaBorderPaint);

    // Mini Kaaba cube icon (Black cube with gold belt)
    final cubeRect = Rect.fromCenter(center: kaabaCenter, width: 14, height: 14);
    final cubePaint = Paint()..color = const Color(0xFF1B1B1B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cubeRect, const Radius.circular(2.5)),
      cubePaint,
    );

    // Gold Kiswah band
    final beltPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(cubeRect.left, cubeRect.top + 4.5),
      Offset(cubeRect.right, cubeRect.top + 4.5),
      beltPaint,
    );

    // Tiny Gold Door
    final doorRect = Rect.fromLTWH(
      kaabaCenter.dx - 1.2,
      kaabaCenter.dy + 1.0,
      2.4,
      4.5,
    );
    final doorPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(doorRect, doorPaint);
  }

  @override
  bool shouldRepaint(covariant _CompassDiscPainter oldDelegate) {
    return oldDelegate.qiblaAngle != qiblaAngle ||
        oldDelegate.isAligned != isAligned;
  }
}

/// Fixed top pointer triangle
class _TopPointerPainter extends CustomPainter {
  final Color color;

  _TopPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // Bottom apex
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TopPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
