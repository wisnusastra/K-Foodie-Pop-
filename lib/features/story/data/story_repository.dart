// lib/features/story/data/story_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/story_chapter.dart';

final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepository();
});

class StoryRepository {
  Future<List<StoryChapter>> fetchChapters() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const [
      StoryChapter(
        day: 1,
        titleKo: '명동 버거 오픈! (Myeongdong Opening)',
        titleId: 'Hari 1: Pembukaan Kedai K-Burger',
        animalGuestName: 'Chef Kapi (카피바라)',
        animalSpecies: 'capybara',
        dialogue:
            'Annyeong! Kedai fast-food hewan pertama kita di sudut Myeongdong resmi buka! Ketuk bahan kembar di rak bawah untuk memasak K-Bulgogi Burger!',
        targetCoins: 360,
      ),
      StoryChapter(
        day: 2,
        titleKo: '토끼의 점심시간 (Tokki Lunch Rush)',
        titleId: 'Hari 2: Jam Makan Siang Tokki',
        animalGuestName: 'Tokki-ya (토끼)',
        animalSpecies: 'bunny',
        dialogue:
            'Kyaa~ aromanya wangi banget! Aku mau Bulgogi Egg Burger lengkap dengan kentang goreng renyah dan susu stroberi Korea ya!',
        targetCoins: 600,
      ),
      StoryChapter(
        day: 3,
        titleKo: '호랑이 단골손님 (Tiger VIP Feast)',
        titleId: 'Hari 3: Pesta VIP Horangi',
        animalGuestName: 'Horangi-kun (호랑이)',
        animalSpecies: 'tiger',
        dialogue:
            'Grrr~ lapar berat habis latihan taekwondo! Siapkan Double Hanwoo Cheese Burger dan K-Fries hangat sekarang!',
        targetCoins: 900,
      ),
    ];
  }
}
