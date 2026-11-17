// lib/features/kitchen/presentation/screens/kitchen_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/game_constants.dart';
import '../../domain/kitchen_models.dart';
import '../providers/kitchen_providers.dart';
import '../widgets/kawaii_animal_avatar.dart';

class KitchenGameScreen extends ConsumerWidget {
  final int dayNumber;

  const KitchenGameScreen({
    super.key,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(kitchenGameProvider(dayNumber));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: gameAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: GameConstants.strawberryPink,
            ),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Terjadi kesalahan dapur: $error'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
          data: (game) {
            if (game.isDayCompleted) {
              return _DayVictoryOverlay(
                dayNumber: game.dayNumber,
                coinsEarned: game.coins,
                servedCount: game.servedCount,
                onBackToStory: () => context.go('/'),
              );
            }

            final notifier = ref.read(kitchenGameProvider(dayNumber).notifier);

            return Column(
              children: [
                _TopHudBar(
                  dayNumber: game.dayNumber,
                  coins: game.coins,
                  targetCoins: game.targetCoins,
                  comboCount: game.comboCount,
                  onExit: () => context.pop(),
                ),
                _CustomerCounterArea(queue: game.customerQueue),
                _ServingCounterBar(
                  trays: game.servingTrays,
                  onTapTray: notifier.serveTrayItem,
                ),
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: GameConstants.strawberryPink.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    game.feedbackBanner,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _CookingStationsRow(stations: game.stations),
                const SizedBox(height: 6),
                Expanded(
                  child: _IngredientPopGrid(
                    grid: game.grid,
                    onTapCell: notifier.tapGridCell,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TopHudBar extends StatelessWidget {
  final int dayNumber;
  final int coins;
  final int targetCoins;
  final int comboCount;
  final VoidCallback onExit;

  const _TopHudBar({
    required this.dayNumber,
    required this.coins,
    required this.targetCoins,
    required this.comboCount,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (coins / targetCoins).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: onExit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GameConstants.hanbokBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Day $dayNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🪙 $coins / $targetCoins Won',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (comboCount > 1)
                      Text(
                        '🔥 Combo x$comboCount',
                        style: const TextStyle(
                          color: GameConstants.strawberryPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: GameConstants.matchaGreen,
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

class _CustomerCounterArea extends StatelessWidget {
  final List<CustomerOrder> queue;

  const _CustomerCounterArea({required this.queue});

  @override
  Widget build(BuildContext context) {
    if (queue.isEmpty) return const SizedBox(height: 110);
    final active = queue.first;
    final waiting = queue.length > 1 ? queue[1] : null;

    return Container(
      height: 126,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD6E0), Color(0xFFFFF0F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameConstants.strawberryPink, width: 2),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KawaiiAnimalAvatar(
                species: active.animal.name == 'Tokki-ya'
                    ? 'bunny'
                    : active.animal.name == 'Horangi'
                        ? 'tiger'
                        : active.animal.name == 'Daram-i'
                            ? 'chipmunk'
                            : 'capybara',
                size: 64,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: active.patienceRatio,
                    minHeight: 6,
                    backgroundColor: Colors.white,
                    color: active.patienceRatio > 0.35
                        ? GameConstants.matchaGreen
                        : Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameConstants.yujaGold, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${active.animal.name} memesan:',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: active.requestedItems.map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GameConstants.yujaGold),
                        ),
                        child: Text(
                          '${item.emoji} ${item.displayName}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          if (waiting != null) ...[
            const SizedBox(width: 8),
            Opacity(
              opacity: 0.75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    waiting.animal.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const Text(
                    'Next',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ServingCounterBar extends StatelessWidget {
  final List<PreparedItemType?> trays;
  final Future<void> Function(int index) onTapTray;

  const _ServingCounterBar({
    required this.trays,
    required this.onTapTray,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GameConstants.woodCounter,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GameConstants.woodCounterDark, width: 2.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(trays.length, (index) {
          final dish = trays[index];
          return GestureDetector(
            onTap: dish != null ? () => onTapTray(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 96,
              height: 58,
              decoration: BoxDecoration(
                color: dish != null ? Colors.white : const Color(0xFFF3E5D8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: dish != null
                      ? GameConstants.matchaGreen
                      : GameConstants.woodCounterDark,
                  width: 2,
                ),
              ),
              child: dish == null
                  ? const Center(
                      child: Text(
                        'Nampan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dish.emoji, style: const TextStyle(fontSize: 22)),
                        const Text(
                          'Ketuk Saji!',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }
}

class _CookingStationsRow extends StatelessWidget {
  final List<CookingStationState> stations;

  const _CookingStationsRow({required this.stations});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: stations.map((station) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF37474F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueGrey.shade700, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        station.iconEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'x${station.rawStock}',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: station.progress,
                      minHeight: 6,
                      backgroundColor: Colors.black38,
                      color: GameConstants.yujaGold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _IngredientPopGrid extends StatelessWidget {
  final List<List<GridCell>> grid;
  final void Function(int row, int col) onTapCell;

  const _IngredientPopGrid({
    required this.grid,
    required this.onTapCell,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 2, 12, 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF5D4037),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3E2723), width: 3),
      ),
      child: Column(
        children: List.generate(grid.length, (r) {
          return Expanded(
            child: Row(
              children: List.generate(grid[r].length, (c) {
                final cell = grid[r][c];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTapCell(r, c),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: cell.type.tileColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cell.type.emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _DayVictoryOverlay extends StatelessWidget {
  final int dayNumber;
  final int coinsEarned;
  final int servedCount;
  final VoidCallback onBackToStory;

  const _DayVictoryOverlay({
    required this.dayNumber,
    required this.coinsEarned,
    required this.servedCount,
    required this.onBackToStory,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: GameConstants.yujaGold, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KawaiiAnimalAvatar(species: 'capybara', size: 84),
            const SizedBox(height: 12),
            Text(
              'Day $dayNumber Sukses! 🎉',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pelanggan Hewan Dilayani: $servedCount
Total Pendapatan: 🪙 $coinsEarned Won',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBackToStory,
              child: const Text('Lanjut Cerita Restoran'),
            ),
          ],
        ),
      ),
    );
  }
}
