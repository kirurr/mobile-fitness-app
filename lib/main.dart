import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dio.dart'; // Import the ApiClient
import 'testing_screen.dart'; // Import the testing screen

Future main() async {
  await dotenv.load(fileName: ".env");

  // Initialize the API client after loading environment variables
  await ApiClient.instance.init();

  runApp(MyApp(title: 'API Testing App'));
}

class MyApp extends StatelessWidget {
  final String title;
  const MyApp({super.key, required this.title});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TestingScreen(), // Replace with the testing screen
    );
  }
}
