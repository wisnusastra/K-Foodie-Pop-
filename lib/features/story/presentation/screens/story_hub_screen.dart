// lib/features/story/presentation/screens/story_hub_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/audio/game_audio_service.dart';
import '../../../../core/constants/game_constants.dart';
import '../../../kitchen/presentation/providers/kitchen_providers.dart';
import '../../../kitchen/presentation/widgets/kawaii_animal_avatar.dart';
import '../../data/story_repository.dart';
import '../../domain/story_chapter.dart';

final storyChaptersProvider = FutureProvider<List<StoryChapter>>((ref) {
  return ref.read(storyRepositoryProvider).fetchChapters();
});

class StoryHubScreen extends ConsumerWidget {
  const StoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(storyChaptersProvider);
    final progressAsync = ref.watch(playerProgressProvider);
    final isMuted = ref.watch(audioMutedProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5EC),
              Color(0xFFFFF8EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(
                  totalCoins: progressAsync.valueOrNull?.totalCoins ?? 0,
                  isMuted: isMuted,
                  onToggleMute: () =>
                      ref.read(gameAudioServiceProvider).toggleMute(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: chaptersAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: GameConstants.strawberryPink,
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text('Gagal memuat cerita: $err'),
                    ),
                    data: (chapters) {
                      final unlockedDay =
                          progressAsync.valueOrNull?.unlockedDay ?? 1;
                      return ListView.separated(
                        itemCount: chapters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          final isUnlocked = chapter.day <= unlockedDay;
                          return _ChapterCard(
                            chapter: chapter,
                            isUnlocked: isUnlocked,
                            onPlay: () {
                              ref
                                  .read(gameAudioServiceProvider)
                                  .playSfx(GameSfx.pop);
                              context.push('/kitchen/${chapter.day}');
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required int totalCoins,
    required bool isMuted,
    required VoidCallback onToggleMute,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GameConstants.strawberryPink, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A4A3222),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const KawaiiAnimalAvatar(
            species: 'capybara',
            size: 62,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'K-Foodie Pop! 🇰🇷',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GameConstants.softChoco,
                  ),
                ),
                Text(
                  'Myeongdong Animal Fast-Food',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onToggleMute,
            tooltip: isMuted ? 'Nyalakan Musik' : 'Bisukan Musik',
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: GameConstants.strawberryPink,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: GameConstants.yujaGold.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$totalCoins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final StoryChapter chapter;
  final bool isUnlocked;
  final VoidCallback onPlay;

  const _ChapterCard({
    required this.chapter,
    required this.isUnlocked,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isUnlocked ? GameConstants.yujaGold : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                KawaiiAnimalAvatar(
                  species: chapter.animalSpecies,
                  size: 56,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.titleKo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${chapter.titleId} • Target: 🪙 ${chapter.targetCoins}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GameConstants.creamBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '"${chapter.dialogue}"',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isUnlocked ? onPlay : null,
                icon: Icon(isUnlocked ? Icons.play_arrow_rounded : Icons.lock),
                label: Text(isUnlocked ? 'Buka Dapur!' : 'Terkunci'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
