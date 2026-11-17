// lib/core/routing/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/kitchen/presentation/screens/kitchen_game_screen.dart';
import '../../features/story/presentation/screens/story_hub_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'story',
        builder: (context, state) => const StoryHubScreen(),
      ),
      GoRoute(
        path: '/kitchen/:day',
        name: 'kitchen',
        builder: (context, state) {
          final day = int.tryParse(state.pathParameters['day'] ?? '1') ?? 1;
          return KitchenGameScreen(dayNumber: day);
        },
      ),
    ],
  );
});
