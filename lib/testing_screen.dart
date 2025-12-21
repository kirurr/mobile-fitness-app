import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/storage.dart';
import 'dio.dart';
import 'auth/service.dart';
import 'auth/model.dart';

class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _testUrlController = TextEditingController();

  String _status = 'Checking auth status...';
  String _result = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      bool isLoggedIn = await _authService.isLoggedIn();
      setState(() {
        _status = isLoggedIn ? 'Signed in' : 'Signed out';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking auth status: $e';
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final result = await _authService.signin(SignInDTO(
        email: _emailController.text,
        password: _passwordController.text,
      ));

      if (result.error != null) {
        setState(() {
          _result = 'Sign in failed: ${result.error!.message}';
        });
      } else {
        setState(() {
          _status = 'Signed in';
          _result = 'Sign in successful!';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Sign in error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final result = await _authService.signup(SignUpDTO(
        email: _emailController.text,
        password: _passwordController.text,
      ));

      if (result.error != null) {
        setState(() {
          _result = 'Sign up failed: ${result.error!.message}';
        });
      } else {
        setState(() {
          _status = 'Signed in';
          _result = 'Sign up successful!';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Sign up error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteToken() async {
    await _storage.deleteToken();
    setState(() {
      _status = 'Not signed in';
      _result = 'Token deleted successfully';
    });
  }

  Future<void> _testConnection() async {
    if (_testUrlController.text.isEmpty) {
      setState(() {
        _result = 'Please enter a URL to test';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await ApiClient.instance.getAuth(_testUrlController.text);
      setState(() {
        _result = 'Connection test successful:\nStatus: ${response.statusCode}\nData: ${response.data}';
      });
    } catch (e) {
      setState(() {
        _result = 'Connection test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Testing Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status display
              Card(
                color: _status.contains('Signed in')
                    ? Colors.green[100]
                    : _status.contains('Not signed in')
                        ? Colors.red[100]
                        : Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Authentication Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_status, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email input
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              // Password input
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Sign in button
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 10),

              // Sign up button
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),

              // Delete token button
              ElevatedButton(
                onPressed: _isLoading ? null : _deleteToken,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete Token', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),

              // Test URL input
              TextField(
                controller: _testUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL to Test (e.g., /api/test)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              // Test connection button
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Test Connection', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),

              // Loading indicator
              if (_isLoading) const LinearProgressIndicator(),

              const SizedBox(height: 20),

              // Result display
              Card(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: SelectableText(_result.isEmpty ? 'Results will appear here...' : _result),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _testUrlController.dispose();
    super.dispose();
  }
}
