import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/driver_api.dart';
import '../ui/driver_design.dart';
import 'loading_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  void _continueToVerify() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      DriverSnack.show(context, 'أدخل رقم الجوال');
      return;
    }

    Navigator.of(
      context,
    ).push(driverRoute(builder: (_) => VerifyScreen(phone: phone)));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 36, 48, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Verify Your Number',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DriverColors.navyPanel,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Only numbers registered in the database can be verified',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF55565D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 46),
            const Text(
              'Phone number',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _PhoneField(controller: _phoneController),
            const SizedBox(height: 46),
            DriverButton(label: 'Next', onPressed: _continueToVerify),
            const SizedBox(height: 32),
            const Text(
              'Need help? Contact support',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF92949C),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.child});

  static const _contentWidth = 390.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: DriverColors.navy,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: DriverColors.softWhite,
        body: Column(
          children: [
            const _AuthHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, required this.phone});

  final String phone;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  static const _demoCode = '0000';

  final _api = createDriverApi();
  String _code = '';
  bool _loading = false;
  bool _canResend = false;

  void _tapDigit(String digit) {
    if (_code.length >= _demoCode.length || _loading) return;
    setState(() => _code += digit);
  }

  void _deleteDigit() {
    if (_code.isEmpty || _loading) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  Future<void> _verify() async {
    if (_code.length < _demoCode.length) {
      DriverSnack.show(context, 'أدخل رمز التحقق المكون من 4 أرقام');
      return;
    }

    if (_code != _demoCode) {
      DriverSnack.show(context, 'رمز التحقق المؤقت هو 0000');
      return;
    }

    setState(() => _loading = true);
    try {
      final session = await _api.driverLogin(phone: widget.phone);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        driverRoute(builder: (_) => LoadingScreen(session: session)),
      );
    } catch (error) {
      if (!mounted) return;
      DriverSnack.show(
        context,
        error.toString().replaceFirst('Exception: ', ''),
      );
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 26),
          const Text(
            'Verify Your Phone Number',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: DriverColors.navyPanel,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter the temporary code 0000',
            style: TextStyle(
              color: Color(0xFF66666B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                _demoCode.length,
                (index) =>
                    _OtpBox(value: index < _code.length ? _code[index] : ''),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              text: 'Didn’t receive the code? ',
              style: const TextStyle(
                color: Color(0xFF66666B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: _canResend ? 'Resend Code' : 'Resend in 00:30',
                  style: const TextStyle(
                    color: DriverColors.orange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 38),
            child: DriverButton(
              label: _loading ? 'Verifying...' : 'Verify',
              onPressed: _loading ? null : _verify,
            ),
          ),
          const Spacer(),
          _NumericKeypad(onDigit: _tapDigit, onDelete: _deleteDigit),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader();

  @override
  Widget build(BuildContext context) {
    final statusTop = MediaQuery.paddingOf(context).top;
    return Container(
      height: statusTop + 276,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: DriverColors.navy,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: statusTop),
        child: Center(
          child: Image.asset(
            DriverAssets.wordmark,
            width: 190,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '+966',
              style: TextStyle(
                color: DriverColors.orange,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.black,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              decoration: const InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: 'Enter your phone number',
                hintStyle: TextStyle(
                  color: Color(0xFFC3C3C3),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.only(top: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({required this.onDigit, required this.onDelete});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 24, 10, 34),
      decoration: const BoxDecoration(
        color: Color(0xFFE1E4E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  for (final digit in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _KeyButton(
                          label: digit,
                          onTap: () => onDigit(digit),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              const Expanded(child: SizedBox(height: 50)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _KeyButton(label: '0', onTap: () => onDigit('0')),
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFF44484F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
