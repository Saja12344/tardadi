import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/user_session.dart';
import '../widgets/onboarding/numeric_keypad.dart';
import '../widgets/onboarding/onboarding_scale.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/onboarding/verification_header.dart';
import 'routes_main_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  var _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    for (final node in _focusNodes) {
      node.canRequestFocus = false;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft == 0) return;
      setState(() => _secondsLeft--);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _onKeyTap(String value) {
    if (value == 'back') {
      for (var i = 5; i >= 0; i--) {
        if (_otpControllers[i].text.isNotEmpty) {
          _otpControllers[i].clear();
          setState(() {});
          return;
        }
      }
      return;
    }

    for (var i = 0; i < 6; i++) {
      if (_otpControllers[i].text.isEmpty) {
        _otpControllers[i].text = value;
        setState(() {});
        return;
      }
    }
  }

  void _verify() {
    if (_otp.length < 6) return;

    if (UserSession.instance.phoneNumber == null) {
      UserSession.instance.setPhoneNumber('+966500000000');
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const RoutesMainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          VerificationHeader(scale: scale, onBack: _goBack),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: scale.horizontalPadding),
              child: Column(
                children: [
                  SizedBox(height: scale.s(20)),
                  Text(
                    l10n.verifyPhoneTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OnboardingTheme.routeTitle,
                      fontSize: scale.verifyTitleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: scale.s(8)),
                  Text(
                    l10n.verifyPhoneSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: OnboardingTheme.routeMeta,
                      fontSize: scale.verifySubtitleSize,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: scale.s(20)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _OtpBox(
                          size: scale.otpBoxSize,
                          height: scale.otpBoxHeight,
                          fontSize: scale.s(22),
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: scale.s(14)),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      text: l10n.didntReceiveCode,
                      style: TextStyle(
                        color: OnboardingTheme.routeMeta,
                        fontSize: scale.s(14),
                      ),
                      children: [
                        TextSpan(
                          text: _secondsLeft > 0
                              ? l10n.resendIn(_timerLabel)
                              : l10n.resendCode,
                          style: TextStyle(
                            color: OnboardingTheme.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: scale.s(14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              scale.horizontalPadding,
              0,
              scale.horizontalPadding,
              scale.s(8),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _otp.length == 6 ? _verify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.orange,
                  foregroundColor: OnboardingTheme.white,
                  disabledBackgroundColor:
                      OnboardingTheme.orange.withValues(alpha: 0.45),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: scale.s(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  l10n.verify,
                  style: TextStyle(
                    fontSize: scale.buttonFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          NumericKeypad(
            keyHeight: scale.s(46),
            keyFontSize: scale.s(22),
            onKeyTap: _onKeyTap,
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.size,
    required this.height,
    required this.fontSize,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double size;
  final double height;
  final double fontSize;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: true,
        showCursor: false,
        keyboardType: TextInputType.none,
        enableInteractiveSelection: false,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: OnboardingTheme.routeTitle,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
