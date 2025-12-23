import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/auth/service.dart';
import 'sign_in_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _guardAuth();
  }

  Future<void> _guardAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    await _authService.signout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deps = DependencyScope.of(context);

    final repo = deps.fitnessGoalRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Main'),
        actions: [
          IconButton(
            onPressed: _isSigningOut ? null : _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: () async {
            await repo.refreshGoals();
          }, child: const Text('Test API')),
          Expanded(
            child: StreamBuilder(
              stream: repo.watchGoals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                // 2. Ошибка стрима
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
            
                // 3. Данные
                final items = snapshot.data ?? [];
            
                if (items.isEmpty) {
                  return const Center(child: Text('Пока пусто'));
                }
            
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(title: Text(item.name));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
