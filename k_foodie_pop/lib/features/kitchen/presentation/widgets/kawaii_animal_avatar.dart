// lib/features/kitchen/presentation/widgets/kawaii_animal_avatar.dart
import 'package:flutter/material.dart';

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
    final (bg, border, emoji, badge) = switch (species) {
      'bunny' => (
          const Color(0xFFFFD6E7),
          const Color(0xFFFF69B4),
          '🐰',
          '🎀',
        ),
      'tiger' => (
          const Color(0xFFFFE0B2),
          const Color(0xFFFF9800),
          '🐯',
          '🥋',
        ),
      'chipmunk' => (
          const Color(0xFFD7CCC8),
          const Color(0xFF795548),
          '🐿️',
          '🌰',
        ),
      _ => (
          const Color(0xFFE6CCB2),
          const Color(0xFF9C6644),
          '🦫',
          '👨‍🍳',
        ),
    };

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 2.5),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(fontSize: size * 0.54),
            ),
          ),
          Positioned(
            top: -4,
            right: -2,
            child: Text(
              badge,
              style: TextStyle(fontSize: size * 0.30),
            ),
          ),
        ],
      ),
    );
  }
}
