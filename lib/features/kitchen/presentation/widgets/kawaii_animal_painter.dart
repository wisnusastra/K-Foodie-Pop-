// lib/features/kitchen/presentation/widgets/kawaii_animal_painter.dart
import 'package:flutter/material.dart';

class KawaiiAnimalPainter extends CustomPainter {
  final String species;

  const KawaiiAnimalPainter({required this.species});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.56);
    final outline = Paint()
      ..color = const Color(0xFF4A3222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (w * 0.038).clamp(1.6, 3.2)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (species) {
      case 'bunny':
        _paintBunny(canvas, w, h, center, outline);
      case 'tiger':
        _paintTiger(canvas, w, h, center, outline);
      case 'chipmunk':
        _paintChipmunk(canvas, w, h, center, outline);
      default:
        _paintCapybaraChef(canvas, w, h, center, outline);
    }
  }

  void _paintCapybaraChef(
    Canvas canvas,
    double w,
    double h,
    Offset c,
    Paint outline,
  ) {
    final furPaint = Paint()..color = const Color(0xFFC68B59);
    final snoutPaint = Paint()..color = const Color(0xFFA4683C);
    final earPaint = Paint()..color = const Color(0xFF8D5524);

    // Round ears
    canvas.drawCircle(Offset(c.dx - w * 0.25, c.dy - h * 0.20), w * 0.08, earPaint);
    canvas.drawCircle(Offset(c.dx - w * 0.25, c.dy - h * 0.20), w * 0.08, outline);
    canvas.drawCircle(Offset(c.dx + w * 0.25, c.dy - h * 0.20), w * 0.08, earPaint);
    canvas.drawCircle(Offset(c.dx + w * 0.25, c.dy - h * 0.20), w * 0.08, outline);

    // Chubby capybara head
    final headRect = Rect.fromCenter(center: c, width: w * 0.64, height: h * 0.52);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.24)), furPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.24)), outline);

    // Snout oval
    final snoutRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + h * 0.06),
      width: w * 0.34,
      height: h * 0.22,
    );
    canvas.drawOval(snoutRect, snoutPaint);
    canvas.drawOval(snoutRect, outline);

    // Puffy white chef toque hat
    final hatFill = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(c.dx - w * 0.13, c.dy - h * 0.34), w * 0.11, hatFill);
    canvas.drawCircle(Offset(c.dx + w * 0.13, c.dy - h * 0.34), w * 0.11, hatFill);
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.38), w * 0.13, hatFill);
    final bandRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - h * 0.25),
      width: w * 0.34,
      height: h * 0.10,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(bandRect, Radius.circular(w * 0.04)), hatFill);
    canvas.drawRRect(RRect.fromRectAndRadius(bandRect, Radius.circular(w * 0.04)), outline);

    // Calm happy eyes, nose, and rosy cheeks
    _drawBlushAndFace(canvas, w, h, c, outline, sleepyEyes: true);
  }

  void _paintBunny(
    Canvas canvas,
    double w,
    double h,
    Offset c,
    Paint outline,
  ) {
    final furPaint = Paint()..color = const Color(0xFFFFE4EE);
    final innerEarPaint = Paint()..color = const Color(0xFFFF9EC4);

    // Lop ears
    for (final dir in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(c.dx + dir * w * 0.24, c.dy - h * 0.14);
      canvas.rotate(dir * 0.35);
      final earRect = Rect.fromCenter(center: Offset(0, h * 0.12), width: w * 0.16, height: h * 0.38);
      canvas.drawOval(earRect, furPaint);
      canvas.drawOval(earRect.deflate(w * 0.03), innerEarPaint);
      canvas.drawOval(earRect, outline);
      canvas.restore();
    }

    // Head
    final headRect = Rect.fromCenter(center: c, width: w * 0.62, height: h * 0.52);
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, outline);

    // Big pink ribbon bow on top
    final bowPaint = Paint()..color = const Color(0xFFFF5C9D);
    final leftBow = Path()
      ..moveTo(c.dx, c.dy - h * 0.26)
      ..lineTo(c.dx - w * 0.16, c.dy - h * 0.36)
      ..lineTo(c.dx - w * 0.14, c.dy - h * 0.20)
      ..close();
    final rightBow = Path()
      ..moveTo(c.dx, c.dy - h * 0.26)
      ..lineTo(c.dx + w * 0.16, c.dy - h * 0.36)
      ..lineTo(c.dx + w * 0.14, c.dy - h * 0.20)
      ..close();
    canvas.drawPath(leftBow, bowPaint);
    canvas.drawPath(leftBow, outline);
    canvas.drawPath(rightBow, bowPaint);
    canvas.drawPath(rightBow, outline);
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.27), w * 0.045, Paint()..color = const Color(0xFFFFD166));
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.27), w * 0.045, outline);

    _drawBlushAndFace(canvas, w, h, c, outline, sleepyEyes: false);
  }

  void _paintTiger(
    Canvas canvas,
    double w,
    double h,
    Offset c,
    Paint outline,
  ) {
    final furPaint = Paint()..color = const Color(0xFFFFB74D);
    final muzzlePaint = Paint()..color = Colors.white;

    // Ears
    for (final dir in [-1.0, 1.0]) {
      final earPos = Offset(c.dx + dir * w * 0.23, c.dy - h * 0.22);
      canvas.drawCircle(earPos, w * 0.09, furPaint);
      canvas.drawCircle(earPos, w * 0.09, outline);
    }

    // Head
    final headRect = Rect.fromCenter(center: c, width: w * 0.64, height: h * 0.54);
    canvas.drawOval(headRect, furPaint);
    canvas.drawOval(headRect, outline);

    // Taekwondo headband
    final bandRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy - h * 0.15),
      width: w * 0.60,
      height: h * 0.09,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bandRect, Radius.circular(w * 0.04)),
      Paint()..color = const Color(0xFF4D96FF),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(bandRect, Radius.circular(w * 0.04)), outline);

    // White muzzle
    final muzzleRect = Rect.fromCenter(
      center: Offset(c.dx, c.dy + h * 0.08),
      width: w * 0.34,
      height: h * 0.20,
    );
    canvas.drawOval(muzzleRect, muzzlePaint);

    _drawBlushAndFace(canvas, w, h, c, outline, sleepyEyes: false);
  }

  void _paintChipmunk(
    Canvas canvas,
    double w,
    double h,
    Offset c,
    Paint outline,
  ) {
    final furPaint = Paint()..color = const Color(0xFFD4A373);
    final cheekPatchPaint = Paint()..color = const Color(0xFFFAEDCD);

    // Round ears
    for (final dir in [-1.0, 1.0]) {
      final earPos = Offset(c.dx + dir * w * 0.22, c.dy - h * 0.22);
      canvas.drawCircle(earPos, w * 0.085, furPaint);
      canvas.drawCircle(earPos, w * 0.085, outline);
    }

    // Chubby pear-shaped cheeks
    final headRect = Rect.fromCenter(center: c, width: w * 0.66, height: h * 0.54);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.26)), furPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.26)), outline);

    // Light cheek puffs
    canvas.drawCircle(Offset(c.dx - w * 0.16, c.dy + h * 0.06), w * 0.10, cheekPatchPaint);
    canvas.drawCircle(Offset(c.dx + w * 0.16, c.dy + h * 0.06), w * 0.10, cheekPatchPaint);

    // Golden acorn hairpin
    canvas.drawCircle(Offset(c.dx + w * 0.16, c.dy - h * 0.21), w * 0.055, Paint()..color = const Color(0xFFFFC857));
    canvas.drawCircle(Offset(c.dx + w * 0.16, c.dy - h * 0.21), w * 0.055, outline);

    _drawBlushAndFace(canvas, w, h, c, outline, sleepyEyes: false);
  }

  void _drawBlushAndFace(
    Canvas canvas,
    double w,
    double h,
    Offset c,
    Paint outline, {
    required bool sleepyEyes,
  }) {
    final eyePaint = Paint()..color = const Color(0xFF3D2618);
    final sparklePaint = Paint()..color = Colors.white;
    final blushPaint = Paint()..color = const Color(0xFFFF8FAB).withOpacity(0.65);

    // Rosy cheeks
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx - w * 0.18, c.dy + h * 0.05), width: w * 0.11, height: h * 0.06),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx + w * 0.18, c.dy + h * 0.05), width: w * 0.11, height: h * 0.06),
      blushPaint,
    );

    if (sleepyEyes) {
      // Cute horizontal relaxed capybara eyes
      canvas.drawLine(
        Offset(c.dx - w * 0.19, c.dy - h * 0.03),
        Offset(c.dx - w * 0.10, c.dy - h * 0.03),
        outline,
      );
      canvas.drawLine(
        Offset(c.dx + w * 0.10, c.dy - h * 0.03),
        Offset(c.dx + w * 0.19, c.dy - h * 0.03),
        outline,
      );
    } else {
      // Big sparkly anime eyes
      for (final dir in [-1.0, 1.0]) {
        final eyeCenter = Offset(c.dx + dir * w * 0.14, c.dy - h * 0.03);
        canvas.drawCircle(eyeCenter, w * 0.048, eyePaint);
        canvas.drawCircle(
          Offset(eyeCenter.dx - w * 0.015, eyeCenter.dy - h * 0.015),
          w * 0.018,
          sparklePaint,
        );
      }
    }

    // Tiny nose and 'w' smile
    canvas.drawCircle(Offset(c.dx, c.dy + h * 0.03), w * 0.025, eyePaint);
    final smilePath = Path()
      ..moveTo(c.dx - w * 0.06, c.dy + h * 0.08)
      ..quadraticBezierTo(c.dx - w * 0.03, c.dy + h * 0.12, c.dx, c.dy + h * 0.08)
      ..quadraticBezierTo(c.dx + w * 0.03, c.dy + h * 0.12, c.dx + w * 0.06, c.dy + h * 0.08);
    canvas.drawPath(smilePath, outline);
  }

  @override
  bool shouldRepaint(covariant KawaiiAnimalPainter oldDelegate) {
    return oldDelegate.species != species;
  }
}
