import 'package:educatitivegame/pages/home/home_page.dart';
import 'package:educatitivegame/pages/auth/login_page.dart';
import 'package:educatitivegame/pages/auth/register_page.dart';
import 'package:educatitivegame/pages/home/loading.dart';
import 'package:educatitivegame/pages/profile/profile_page.dart';
import 'package:educatitivegame/pages/quiz/quizDif_page.dart';
import 'package:educatitivegame/pages/quiz/quizLevel_page.dart';
import 'package:educatitivegame/pages/score/score_page.dart';
import 'package:educatitivegame/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(),
      routes: {
        '/home': (context) { return HomePage(); },
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/score': (context) { return ScorePage(); },
        '/difficulty': (context) { return QuizDifficultyPage(); },
        '/profile': (context) => const  ProfilePage(),
        '/quiz': (context) {
          final args = ModalRoute.of(context)!.settings.arguments 
              as Map<String, dynamic>;
          return QuizPage(
            difficultyLevel: args['difficultyLevel']
          );
        },
      },
    );
  }
}