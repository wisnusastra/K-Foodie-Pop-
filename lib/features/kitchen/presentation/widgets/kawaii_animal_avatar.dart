// lib/features/kitchen/presentation/widgets/kawaii_animal_avatar.dart
import 'package:flutter/material.dart';
import 'kawaii_animal_painter.dart';

class KawaiiAnimalAvatar extends StatelessWidget {
  final String species;
  final double size;

  const KawaiiAnimalAvatar({
    super.key,
    required this.species,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (species) {
      'bunny' => (const Color(0xFFFFF0F6), const Color(0xFFFF69B4)),
      'tiger' => (const Color(0xFFFFF3E0), const Color(0xFFFF9800)),
      'chipmunk' => (const Color(0xFFFDF6EC), const Color(0xFF9C6644)),
      _ => (const Color(0xFFFFF8E7), const Color(0xFF8D5524)),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F4A3222),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: KawaiiAnimalPainter(species: species),
        ),
      ),
    );
  }
}
