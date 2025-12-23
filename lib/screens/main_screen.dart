import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/auth/service.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/screens/user_data_form_screen.dart';
import 'sign_in_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningOut = false;
  bool _promptedUserData = false;
  bool _checkingUserData = true;

  @override
  void initState() {
    super.initState();
    _guardAuth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _checkUserDataOnStart();
    });
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

  Future<void> _refreshUserData() async {
    try {
      final deps = DependencyScope.of(context);
      await deps.userDataRepository.refreshUserData();
    } catch (_) {
      // Allow offline/local-first behavior even if refresh fails.
    }
  }

  Future<void> _checkUserDataOnStart() async {
    if (_promptedUserData) return;
    final deps = DependencyScope.of(context);
    final userRepo = deps.userDataRepository;
    try {
      final first = await userRepo.watchUserData().first;
      if (first == null && mounted) {
        _promptedUserData = true;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const UserDataFormScreen(),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingUserData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUserData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final deps = DependencyScope.of(context);

    final fitnessRepo = deps.fitnessGoalRepository;
    final difficlutyRepo = deps.difficultyLevelRepository;
    final userRepo = deps.userDataRepository;

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
          ElevatedButton(
            onPressed: () async {
              await fitnessRepo.refreshGoals();
              await difficlutyRepo.refreshLevels();
              await _refreshUserData();
            },
            child: const Text('Test API'),
          ),
          StreamBuilder<UserData?>(
            stream: userRepo.watchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final userData = snapshot.data;
              if (userData == null) {
                if (!_promptedUserData) {
                  _promptedUserData = true;
                  Future.microtask(() {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const UserDataFormScreen(),
                      ),
                    );
                  });
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No user data found. Please complete your profile.'),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Name: ${userData.name}'),
                    Text('Age: ${userData.age}'),
                    Text('Weight: ${userData.weight}'),
                    Text('Height: ${userData.height}'),
                    Text('Fitness Goal ID: ${userData.fitnessGoal.value?.name}'),
                    Text('Training Level: ${userData.trainingLevel.value?.name}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _refreshUserData,
                      child: const Text('Refresh user data'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: difficlutyRepo.watchLevels(),
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
          Expanded(
            child: StreamBuilder(
              stream: fitnessRepo.watchGoals(),
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
