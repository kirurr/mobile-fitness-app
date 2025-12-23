import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'auth/service.dart';
import 'screens/main_screen.dart';
import 'screens/sign_in_screen.dart';

Future main() async {
  final deps = await Dependencies.init();
  runApp(
    DependencyScope(
      deps: deps,
      child: const MyApp(title: 'Mobile Fitness App'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String title;
  const MyApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const MainScreen() : const SignInScreen();
      },
    );
  }
}
