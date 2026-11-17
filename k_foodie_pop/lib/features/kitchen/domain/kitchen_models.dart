// lib/features/kitchen/domain/kitchen_models.dart
import 'package:flutter/material.dart';

enum RawIngredientType {
  patty('Daging Hanwoo', '🥩', Color(0xFFFFCDD2)),
  egg('Telur Segar', '🥚', Color(0xFFFFF9C4)),
  potato('Kentang Korea', '🥔', Color(0xFFFFE0B2)),
  cheese('Keju Cheddar', '🧀', Color(0xFFFFF59D)),
  lettuce('Selada Segar', '🥬', Color(0xFFC8E6C9)),
  tomato('Tomat Merah', '🍅', Color(0xFFFFCCBC));

  final String label;
  final String emoji;
  final Color tileColor;
  const RawIngredientType(this.label, this.emoji, this.tileColor);
}

enum PreparedItemType {
  bulgogiBurger('K-Bulgogi Burger', '🍔'),
  eggCheeseBurger('K-Egg Cheese Burger', '🥪'),
  koreanFries('Honey Butter Fries', '🍟'),
  strawberryMilk('Seoul Berry Milk', '🧃');

  final String displayName;
  final String emoji;
  const PreparedItemType(this.displayName, this.emoji);
}

enum AnimalCharacterType {
  bunny('Tokki-ya', '🐰', Color(0xFFFFB7D5), Color(0xFFFF4D94)),
  capybara('Chef Kapi', '🦫', Color(0xFFD7A87E), Color(0xFF8D5B3C)),
  tiger('Horangi', '🐯', Color(0xFFFFCC80), Color(0xFFE65100)),
  chipmunk('Daram-i', '🐿️', Color(0xFFBCAAA4), Color(0xFF5D4037));

  final String name;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;
  const AnimalCharacterType(
    this.name,
    this.emoji,
    this.primaryColor,
    this.accentColor,
  );
}

class GridCell {
  final int row;
  final int col;
  final RawIngredientType type;

  const GridCell({
    required this.row,
    required this.col,
    required this.type,
  });

  GridCell copyWith({
    int? row,
    int? col,
    RawIngredientType? type,
  }) {
    return GridCell(
      row: row ?? this.row,
      col: col ?? this.col,
      type: type ?? this.type,
    );
  }
}

class CustomerOrder {
  final String id;
  final AnimalCharacterType animal;
  final List<PreparedItemType> requestedItems;
  final int remainingSeconds;
  final int maxSeconds;

  const CustomerOrder({
    required this.id,
    required this.animal,
    required this.requestedItems,
    required this.remainingSeconds,
    required this.maxSeconds,
  });

  double get patienceRatio =>
      maxSeconds == 0 ? 0 : (remainingSeconds / maxSeconds).clamp(0.0, 1.0);

  CustomerOrder copyWith({
    String? id,
    AnimalCharacterType? animal,
    List<PreparedItemType>? requestedItems,
    int? remainingSeconds,
    int? maxSeconds,
  }) {
    return CustomerOrder(
      id: id ?? this.id,
      animal: animal ?? this.animal,
      requestedItems: requestedItems ?? this.requestedItems,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      maxSeconds: maxSeconds ?? this.maxSeconds,
    );
  }
}

class CookingStationState {
  final String id;
  final String title;
  final String iconEmoji;
  final int rawStock;
  final double progress;
  final PreparedItemType outputItem;

  const CookingStationState({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.rawStock,
    required this.progress,
    required this.outputItem,
  });

  bool get isCooking => rawStock > 0 && progress < 1.0;

  CookingStationState copyWith({
    int? rawStock,
    double? progress,
  }) {
    return CookingStationState(
      id: id,
      title: title,
      iconEmoji: iconEmoji,
      rawStock: rawStock ?? this.rawStock,
      progress: progress ?? this.progress,
      outputItem: outputItem,
    );
  }
}

class KitchenGameState {
  final int dayNumber;
  final int coins;
  final int targetCoins;
  final int comboCount;
  final int servedCount;
  final List<List<GridCell>> grid;
  final List<CustomerOrder> customerQueue;
  final List<PreparedItemType?> servingTrays;
  final List<CookingStationState> stations;
  final String feedbackBanner;
  final bool isDayCompleted;

  const KitchenGameState({
    required this.dayNumber,
    required this.coins,
    required this.targetCoins,
    required this.comboCount,
    required this.servedCount,
    required this.grid,
    required this.customerQueue,
    required this.servingTrays,
    required this.stations,
    required this.feedbackBanner,
    required this.isDayCompleted,
  });

  KitchenGameState copyWith({
    int? dayNumber,
    int? coins,
    int? targetCoins,
    int? comboCount,
    int? servedCount,
    List<List<GridCell>>? grid,
    List<CustomerOrder>? customerQueue,
    List<PreparedItemType?>? servingTrays,
    List<CookingStationState>? stations,
    String? feedbackBanner,
    bool? isDayCompleted,
  }) {
    return KitchenGameState(
      dayNumber: dayNumber ?? this.dayNumber,
      coins: coins ?? this.coins,
      targetCoins: targetCoins ?? this.targetCoins,
      comboCount: comboCount ?? this.comboCount,
      servedCount: servedCount ?? this.servedCount,
      grid: grid ?? this.grid,
      customerQueue: customerQueue ?? this.customerQueue,
      servingTrays: servingTrays ?? this.servingTrays,
      stations: stations ?? this.stations,
      feedbackBanner: feedbackBanner ?? this.feedbackBanner,
      isDayCompleted: isDayCompleted ?? this.isDayCompleted,
    );
  }
}
