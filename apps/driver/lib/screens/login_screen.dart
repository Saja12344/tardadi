import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
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
  final _phoneFocusNode = FocusNode();

  void _showPhoneKeyboard() {
    _phoneFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  void _continueToVerify() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      DriverSnack.show(context, context.l10n.enterPhone);
      return;
    }

    Navigator.of(context).push(
      driverRoute(builder: (_) => VerifyScreen(phone: phone)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showPhoneKeyboard();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(48, 36, 48, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.verifyYourNumber,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DriverColors.navyPanel,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.onlyRegisteredNumbers,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF55565D),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 46),
            Text(
              l10n.phoneNumber,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _PhoneField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              onTap: _showPhoneKeyboard,
              hintText: l10n.enterPhoneNumber,
            ),
            const SizedBox(height: 46),
            DriverButton(label: l10n.next, onPressed: _continueToVerify),
            const SizedBox(height: 32),
            Text(
              l10n.needHelp,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
    return DriverChrome(
      bodyColor: DriverColors.softWhite,
      child: Column(
        children: [
          const _AuthHeader(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _contentWidth),
                child: child,
              ),
            ),
          ),
        ],
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
  static const _demoCode = '000000';
  static const _codeLength = 6;

  final _api = createDriverApi();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  String _code = '';
  bool _loading = false;
  int _resendSeconds = 30;
  Timer? _resendTimer;

  void _showOtpKeyboard() {
    _otpFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  void _updateCode(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final nextCode = digitsOnly.length > _codeLength
        ? digitsOnly.substring(0, _codeLength)
        : digitsOnly;
    if (_otpController.text != nextCode) {
      _otpController.value = TextEditingValue(
        text: nextCode,
        selection: TextSelection.collapsed(offset: nextCode.length),
      );
    }
    if (_code != nextCode) {
      setState(() => _code = nextCode);
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds -= 1);
    });
  }

  void _resendCode() {
    if (_resendSeconds > 0) return;
    _otpController.clear();
    setState(() => _code = '');
    _startResendTimer();
    DriverSnack.show(context, context.l10n.codeResent);
  }

  Future<void> _verify() async {
    if (_code.length < _codeLength) {
      DriverSnack.show(context, context.l10n.enterOtp);
      return;
    }

    if (_code != _demoCode) {
      DriverSnack.show(context, context.l10n.demoOtpHint);
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
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _showOtpKeyboard();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String _resendLabel(BuildContext context) {
    final l10n = context.l10n;
    if (_resendSeconds == 0) return l10n.resendCode;
    final seconds = _resendSeconds.toString().padLeft(2, '0');
    return l10n.resendIn(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _AuthScaffold(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 12),
              child: Column(
                children: [
                  Text(
                    l10n.verifyYourPhoneNumber,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DriverColors.navyPanel,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.enterSixDigitCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF66666B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            _codeLength,
                            (index) => _OtpBox(
                              value: index < _code.length ? _code[index] : '',
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: _showOtpKeyboard,
                            behavior: HitTestBehavior.translucent,
                            child: Opacity(
                              opacity: 0.02,
                              child: TextField(
                                controller: _otpController,
                                focusNode: _otpFocusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.oneTimeCode],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(_codeLength),
                                ],
                                onChanged: _updateCode,
                                onSubmitted: (_) {
                                  if (!_loading) _verify();
                                },
                                showCursor: false,
                                style: const TextStyle(
                                  color: Colors.transparent,
                                  fontSize: 18,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _resendSeconds == 0 ? _resendCode : null,
                    child: Text.rich(
                      TextSpan(
                        text: l10n.didntReceiveCode,
                        style: const TextStyle(
                          color: Color(0xFF66666B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: _resendLabel(context),
                            style: const TextStyle(
                              color: DriverColors.orange,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DriverButton(
                      label: _loading ? l10n.verifying : l10n.verify,
                      onPressed: _loading ? null : _verify,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.onTap,
    required this.hintText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTap;
  final String hintText;

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
              color: const Color(0xFFDCE8F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '+966',
              style: TextStyle(
                color: DriverColors.navyPanel,
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
              focusNode: focusNode,
              onTap: onTap,
              autofocus: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.black, fontSize: 18),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFC3C3C3),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.only(top: 2),
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
      width: 44,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
