// lib/features/kitchen/presentation/providers/kitchen_providers.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/game_constants.dart';
import '../../data/progression_repository.dart';
import '../../domain/kitchen_models.dart';

final playerProgressProvider =
    AsyncNotifierProvider<PlayerProgressNotifier, PlayerProgress>(
  PlayerProgressNotifier.new,
);

class PlayerProgressNotifier extends AsyncNotifier<PlayerProgress> {
  @override
  Future<PlayerProgress> build() async {
    final repo = ref.read(progressionRepositoryProvider);
    return repo.loadProgress();
  }

  Future<void> recordDayCompletion(int day, int coins) async {
    final repo = ref.read(progressionRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => repo.completeDay(dayCompleted: day, earnedCoins: coins),
    );
  }
}

final kitchenGameProvider = AsyncNotifierProvider.family<KitchenGameNotifier,
    KitchenGameState, int>(
  KitchenGameNotifier.new,
);

class KitchenGameNotifier extends FamilyAsyncNotifier<KitchenGameState, int> {
  final _random = Random();
  Timer? _gameLoopTimer;

  @override
  Future<KitchenGameState> build(int arg) async {
    ref.onDispose(() {
      _gameLoopTimer?.cancel();
    });

    final target = switch (arg) {
      1 => 360,
      2 => 600,
      _ => 900,
    };

    final initialState = KitchenGameState(
      dayNumber: arg,
      coins: 0,
      targetCoins: target,
      comboCount: 0,
      servedCount: 0,
      grid: _generateInitialGrid(),
      customerQueue: [
        _spawnCustomer(arg, 1),
        _spawnCustomer(arg, 2),
      ],
      servingTrays: const [null, null, null],
      stations: const [
        CookingStationState(
          id: 'grill_burger',
          title: 'Grill Bulgogi',
          iconEmoji: '🍳',
          rawStock: 0,
          progress: 0,
          outputItem: PreparedItemType.bulgogiBurger,
        ),
        CookingStationState(
          id: 'grill_egg',
          title: 'Egg & Cheese',
          iconEmoji: '🧀',
          rawStock: 0,
          progress: 0,
          outputItem: PreparedItemType.eggCheeseBurger,
        ),
        CookingStationState(
          id: 'fryer_fries',
          title: 'K-Fryer',
          iconEmoji: '🍟',
          rawStock: 0,
          progress: 0,
          outputItem: PreparedItemType.koreanFries,
        ),
        CookingStationState(
          id: 'drink_station',
          title: 'Berry Milk',
          iconEmoji: '🥤',
          rawStock: 0,
          progress: 0,
          outputItem: PreparedItemType.strawberryMilk,
        ),
      ],
      feedbackBanner: 'Ketuk 2+ bahan kembar di bawah untuk mulai memasak!',
      isDayCompleted: false,
    );

    _startGameLoop();
    return initialState;
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      final current = state.valueOrNull;
      if (current == null || current.isDayCompleted) return;

      var trays = List<PreparedItemType?>.from(current.servingTrays);
      final updatedStations = <CookingStationState>[];
      var banner = current.feedbackBanner;

      for (final station in current.stations) {
        if (station.rawStock > 0) {
          final nextProgress = station.progress + 0.14;
          if (nextProgress >= 1.0) {
            final emptyTrayIdx = trays.indexWhere((item) => item == null);
            if (emptyTrayIdx != -1) {
              trays[emptyTrayIdx] = station.outputItem;
              banner =
                  '${station.outputItem.emoji} ${station.outputItem.displayName} siap di nampan!';
              updatedStations.add(
                station.copyWith(
                  rawStock: station.rawStock - 1,
                  progress: 0.0,
                ),
              );
            } else {
              updatedStations.add(station.copyWith(progress: 1.0));
            }
          } else {
            updatedStations.add(station.copyWith(progress: nextProgress));
          }
        } else {
          updatedStations.add(station);
        }
      }

      var updatedQueue = List<CustomerOrder>.from(current.customerQueue);
      var combo = current.comboCount;
      if (timer.tick % 4 == 0 && updatedQueue.isNotEmpty) {
        final front = updatedQueue.first;
        if (front.remainingSeconds > 1) {
          updatedQueue[0] = front.copyWith(
            remainingSeconds: front.remainingSeconds - 1,
          );
        } else {
          updatedQueue.removeAt(0);
          updatedQueue.add(_spawnCustomer(current.dayNumber, timer.tick));
          combo = 0;
          banner =
              'Yah, ${front.animal.name} kelamaan menunggu! Ayo lebih cepat!';
        }
      }

      state = AsyncValue.data(
        current.copyWith(
          stations: updatedStations,
          servingTrays: trays,
          customerQueue: updatedQueue,
          comboCount: combo,
          feedbackBanner: banner,
        ),
      );
    });
  }

  void tapGridCell(int row, int col) {
    final current = state.valueOrNull;
    if (current == null || current.isDayCompleted) return;

    final targetType = current.grid[row][col].type;
    final connected = _findConnectedCells(current.grid, row, col, targetType);

    if (connected.length < 2) {
      state = AsyncValue.data(
        current.copyWith(
          feedbackBanner:
              'Pilih minimal 2 ${targetType.emoji} ${targetType.label} yang bersebelahan!',
        ),
      );
      return;
    }

    final newGrid = _collapseAndRefillGrid(current.grid, connected);

    final stationIndex = switch (targetType) {
      RawIngredientType.patty || RawIngredientType.lettuce => 0,
      RawIngredientType.egg || RawIngredientType.cheese => 1,
      RawIngredientType.potato => 2,
      RawIngredientType.tomato => 3,
    };

    final updatedStations = List<CookingStationState>.from(current.stations);
    final chosenStation = updatedStations[stationIndex];
    final addedBatches = (connected.length / 2).floor().clamp(1, 3);
    updatedStations[stationIndex] = chosenStation.copyWith(
      rawStock: (chosenStation.rawStock + addedBatches).clamp(0, 5),
    );

    state = AsyncValue.data(
      current.copyWith(
        grid: newGrid,
        stations: updatedStations,
        feedbackBanner:
            'Pop x${connected.length}! ${chosenStation.iconEmoji} ${chosenStation.title} mulai memasak!',
      ),
    );
  }

  Future<void> serveTrayItem(int trayIndex) async {
    final current = state.valueOrNull;
    if (current == null || current.isDayCompleted) return;

    final dish = current.servingTrays[trayIndex];
    if (dish == null || current.customerQueue.isEmpty) return;

    final frontCustomer = current.customerQueue.first;
    final neededIndex = frontCustomer.requestedItems.indexOf(dish);

    final updatedTrays = List<PreparedItemType?>.from(current.servingTrays);
    updatedTrays[trayIndex] = null;

    if (neededIndex == -1) {
      state = AsyncValue.data(
        current.copyWith(
          servingTrays: updatedTrays,
          comboCount: 0,
          feedbackBanner:
              '${frontCustomer.animal.name} tidak memesan ${dish.displayName}!',
        ),
      );
      return;
    }

    final remainingItems = List<PreparedItemType>.from(
      frontCustomer.requestedItems,
    )..removeAt(neededIndex);

    final updatedQueue = List<CustomerOrder>.from(current.customerQueue);
    var coins = current.coins;
    var combo = current.comboCount + 1;
    var served = current.servedCount;
    var banner = '${dish.emoji} Diberikan ke ${frontCustomer.animal.name}!';

    if (remainingItems.isEmpty) {
      final bonus = combo * 25;
      coins += GameConstants.baseOrderReward + bonus;
      served += 1;
      updatedQueue.removeAt(0);
      updatedQueue.add(
        _spawnCustomer(current.dayNumber, served + _random.nextInt(999)),
      );
      banner =
          'Kamsahamnida! ${frontCustomer.animal.emoji} ${frontCustomer.animal.name} puas! +${GameConstants.baseOrderReward + bonus} Won!';
    } else {
      updatedQueue[0] = frontCustomer.copyWith(
        requestedItems: remainingItems,
      );
    }

    final completed = coins >= current.targetCoins;
    if (completed) {
      _gameLoopTimer?.cancel();
      await ref
          .read(playerProgressProvider.notifier)
          .recordDayCompletion(current.dayNumber, coins);
    }

    state = AsyncValue.data(
      current.copyWith(
        coins: coins,
        comboCount: combo,
        servedCount: served,
        servingTrays: updatedTrays,
        customerQueue: updatedQueue,
        feedbackBanner: banner,
        isDayCompleted: completed,
      ),
    );
  }

  List<List<GridCell>> _generateInitialGrid() {
    const types = RawIngredientType.values;
    return List.generate(
      GameConstants.gridRows,
      (r) => List.generate(
        GameConstants.gridCols,
        (c) => GridCell(
          row: r,
          col: c,
          type: types[_random.nextInt(types.length)],
        ),
      ),
    );
  }

  Set<(int, int)> _findConnectedCells(
    List<List<GridCell>> grid,
    int startRow,
    int startCol,
    RawIngredientType targetType,
  ) {
    final visited = <(int, int)>{};
    final queue = <(int, int)>[(startRow, startCol)];

    while (queue.isNotEmpty) {
      final (r, c) = queue.removeLast();
      if (r < 0 ||
          r >= GameConstants.gridRows ||
          c < 0 ||
          c >= GameConstants.gridCols) {
        continue;
      }
      if (visited.contains((r, c))) continue;
      if (grid[r][c].type != targetType) continue;

      visited.add((r, c));
      queue.add((r - 1, c));
      queue.add((r + 1, c));
      queue.add((r, c - 1));
      queue.add((r, c + 1));
    }
    return visited;
  }

  List<List<GridCell>> _collapseAndRefillGrid(
    List<List<GridCell>> grid,
    Set<(int, int)> popped,
  ) {
    const types = RawIngredientType.values;
    final nextGrid = List.generate(
      GameConstants.gridRows,
      (r) => List<GridCell>.from(grid[r]),
    );

    for (int col = 0; col < GameConstants.gridCols; col++) {
      final survivingTypes = <RawIngredientType>[];
      for (int row = GameConstants.gridRows - 1; row >= 0; row--) {
        if (!popped.contains((row, col))) {
          survivingTypes.add(grid[row][col].type);
        }
      }
      while (survivingTypes.length < GameConstants.gridRows) {
        survivingTypes.add(types[_random.nextInt(types.length)]);
      }
      for (int row = GameConstants.gridRows - 1; row >= 0; row--) {
        final newType = survivingTypes[GameConstants.gridRows - 1 - row];
        nextGrid[row][col] = GridCell(row: row, col: col, type: newType);
      }
    }
    return nextGrid;
  }

  CustomerOrder _spawnCustomer(int day, int seed) {
    const animals = AnimalCharacterType.values;
    const menu = PreparedItemType.values;
    final animal = animals[(day + seed) % animals.length];
    final orderCount = day == 1 ? 1 : (1 + _random.nextInt(2));
    final items = List.generate(
      orderCount,
      (_) => menu[_random.nextInt(menu.length)],
    );
    return CustomerOrder(
      id: 'cust_${day}_$seed',
      animal: animal,
      requestedItems: items,
      remainingSeconds: GameConstants.maxCustomerPatienceSeconds,
      maxSeconds: GameConstants.maxCustomerPatienceSeconds,
    );
  }
}
