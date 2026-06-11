import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../services/session_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _api = TardadiApi();
  final _driverCodeController = TextEditingController(text: 'DRV-102');
  final _busIdController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_driverCodeController.text.isEmpty || _busIdController.text.isEmpty) {
      _showError('أدخل كود السائق ومعرّف الباص');
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await _api.driverLogin(
        driverCode: _driverCodeController.text.trim(),
        busId: _busIdController.text.trim(),
      );
      SessionStore.instance.set(session);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/map');
    } catch (error) {
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'ترددي',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: TardadiBrand.orange,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Text(
                'تطبيق السائق',
                style: TextStyle(color: TardadiBrand.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _driverCodeController,
                decoration: const InputDecoration(
                  hintText: 'كود السائق',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _busIdController,
                decoration: const InputDecoration(
                  hintText: 'معرّف الباص (busId من Admin)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: Text(_loading ? 'جاري الدخول...' : 'دخول'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
