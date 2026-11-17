// lib/features/story/domain/story_chapter.dart
class StoryChapter {
  final int day;
  final String titleKo;
  final String titleId;
  final String animalGuestName;
  final String animalSpecies;
  final String dialogue;
  final int targetCoins;

  const StoryChapter({
    required this.day,
    required this.titleKo,
    required this.titleId,
    required this.animalGuestName,
    required this.animalSpecies,
    required this.dialogue,
    required this.targetCoins,
  });

  factory StoryChapter.fromJson(Map<String, dynamic> json) {
    return StoryChapter(
      day: json['day'] as int,
      titleKo: json['titleKo'] as String,
      titleId: json['titleId'] as String,
      animalGuestName: json['animalGuestName'] as String,
      animalSpecies: json['animalSpecies'] as String,
      dialogue: json['dialogue'] as String,
      targetCoins: json['targetCoins'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'titleKo': titleKo,
        'titleId': titleId,
        'animalGuestName': animalGuestName,
        'animalSpecies': animalSpecies,
        'dialogue': dialogue,
        'targetCoins': targetCoins,
      };
}
