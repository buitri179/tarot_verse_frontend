import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarot_verse_frontend/data/tarot_data.dart';
import 'package:tarot_verse_frontend/models/tarot_card.dart';
import 'package:tarot_verse_frontend/screens/auth_screen.dart';
import 'package:tarot_verse_frontend/screens/card_meaning_screen.dart';
import 'package:tarot_verse_frontend/screens/conclusion_screen.dart';
import 'package:tarot_verse_frontend/screens/deck_screen.dart';
import 'package:tarot_verse_frontend/screens/history_screen.dart';
import 'package:tarot_verse_frontend/screens/landing_screen.dart';
import 'package:tarot_verse_frontend/screens/results_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TarotDataService.instance.loadCardsFromJson();
  runApp(const TarotGalaxyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LandingScreen();
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
    GoRoute(
        path: '/deck',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return DeckScreen(
            topics: extra['topics'] as List<String>,
            name: extra['name'] as String,
            birthDate: extra['birthDate'] as DateTime,
            gender: extra['gender'] as String,
          );
        }),
    GoRoute(
        path: '/results',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultsScreen(
            selectedCards: extra?['selectedCards'] as List<TarotCardModel>?,
            topics: extra?['topics'] as List<String>?,
            name: extra?['name'] as String?,
            birthDate: extra?['birthDate'] as DateTime?,
            gender: extra?['gender'] as String?,
          );
        }),
    GoRoute(
        path: '/conclusion',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>;
          return ConclusionScreen(
            selected: extra['selected'] as List<TarotCardModel>,
            topics: extra['topics'] as List<String>,
            name: extra['name'] as String,
            birthDate: extra['birthDate'] as DateTime,
            gender: extra['gender'] as String,
            reading: extra['reading'] as String,
          );
        }),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) {
        return const HistoryScreen();
      },
    ),
    GoRoute(
      path: '/card-meaning',
      builder: (BuildContext context, GoRouterState state) {
        return const CardMeaningScreen();
      },
    ),
    GoRoute(
      path: '/share/reading/:readingId',
      builder: (BuildContext context, GoRouterState state) {
        final readingId = state.pathParameters['readingId'];
        return ResultsScreen(readingId: readingId);
      },
    ),
  ],
);

class TarotGalaxyApp extends StatelessWidget {
  const TarotGalaxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Mystic Tarot Galaxy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff8b5cf6),
        scaffoldBackgroundColor: const Color(0xff090A0F),
        textTheme: GoogleFonts.cinzelDecorativeTextTheme().copyWith(
          bodyLarge: const TextStyle(color: Color(0xffe0d6e9)),
          bodyMedium: const TextStyle(color: Color(0xffe0d6e9)),
          displayLarge: const TextStyle(color: Color(0xffe0d6e9)),
          displayMedium: const TextStyle(color: Color(0xffe0d6e9)),
          displaySmall: const TextStyle(color: Color(0xffe0d6e9)),
          headlineLarge: const TextStyle(color: Color(0xffe0d6e9)),
          headlineMedium: const TextStyle(color: Color(0xffe0d6e9)),
          headlineSmall: const TextStyle(color: Color(0xffe0d6e9)),
          titleLarge: const TextStyle(color: Color(0xffe0d6e9)),
          titleMedium: const TextStyle(color: Color(0xffe0d6e9)),
          titleSmall: const TextStyle(color: Color(0xffe0d6e9)),
          labelLarge: const TextStyle(color: Color(0xffe0d6e9)),
          labelMedium: const TextStyle(color: Color(0xffe0d6e9)),
          labelSmall: const TextStyle(color: Color(0xffe0d6e9)),
        ),
        dialogBackgroundColor: const Color(0xff1B2735),
      ),
    );
  }
}
