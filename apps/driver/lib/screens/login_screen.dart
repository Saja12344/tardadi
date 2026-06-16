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
  final _phoneController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('أدخل رقم الجوال');
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await _api.driverLogin(phone: phone);
      SessionStore.instance.set(session);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/map');
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
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
              const SizedBox(height: 8),
              const Text(
                'أدخل رقم جوالك المسجّل من الإدارة',
                style: TextStyle(color: TardadiBrand.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: '05xxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
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
