import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependencies.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/navigation.dart';
import 'package:mobile_fitness_app/app/route_observer.dart';
import 'auth/service.dart';
import 'screens/app_shell.dart';
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
    const colorPrimary = Color(0xFF13EC49);
    const colorBackgroundDark = Color(0xFF102215);
    const colorSurfaceDark = Color(0xFF1C271E);
    const colorTextSecondary = Color(0xFF9DB9A4);

    final darkScheme = ColorScheme.fromSeed(
      seedColor: colorPrimary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: colorPrimary,
      secondary: colorPrimary,
      surface: colorSurfaceDark,
      onSurface: Colors.white,
    );

    return MaterialApp(
      title: title,
      navigatorKey: appNavigatorKey,
      navigatorObservers: [appRouteObserver],
      theme: ThemeData(
        fontFamily: 'Lexend',
        colorScheme: darkScheme,
        scaffoldBackgroundColor: colorBackgroundDark,
        canvasColor: colorBackgroundDark,
        cardColor: colorSurfaceDark,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: colorTextSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrimary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
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
        return isLoggedIn ? const AppShell() : const SignInScreen();
      },
    );
  }
}
