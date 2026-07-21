import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/user_session.dart';
import '../widgets/onboarding/onboarding_scale.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/onboarding/verification_header.dart';
import 'verify_phone_screen.dart';

class EnterPhoneScreen extends StatefulWidget {
  const EnterPhoneScreen({super.key, this.fromSettings = false});

  final bool fromSettings;

  @override
  State<EnterPhoneScreen> createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  String? _error;

  bool get _isValid => _phoneController.text.trim().length >= 9;

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _continue() {
    final digits = _phoneController.text.trim();
    if (digits.length < 9) {
      setState(() => _error = context.l10n.invalidPhone);
      return;
    }

    UserSession.instance.setPhoneNumber('+966$digits');
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VerifyPhoneScreen(fromSettings: widget.fromSettings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            VerificationHeader(scale: scale, onBack: _goBack),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: scale.horizontalPadding),
                child: Column(
                  children: [
                    SizedBox(height: scale.s(20)),
                    Text(
                      l10n.verifyYourNumber,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: OnboardingTheme.routeTitle,
                        fontSize: scale.verifyTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: scale.s(8)),
                    Text(
                      l10n.verifyNumberSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: OnboardingTheme.routeMeta,
                        fontSize: scale.verifySubtitleSize,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: scale.s(24)),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.phoneNumber,
                        style: TextStyle(
                          color: OnboardingTheme.routeTitle,
                          fontSize: scale.s(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: scale.s(8)),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: scale.s(14),
                              vertical: scale.s(16),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Text(
                              '+966',
                              style: TextStyle(
                                color: OnboardingTheme.routeTitle,
                                fontSize: scale.s(16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: scale.s(10)),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              onChanged: (_) => setState(() => _error = null),
                              style: TextStyle(
                                color: OnboardingTheme.routeTitle,
                                fontSize: scale.s(16),
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.phonePlaceholder,
                                hintStyle: TextStyle(
                                  color: OnboardingTheme.routeMeta
                                      .withValues(alpha: 0.7),
                                  fontSize: scale.s(16),
                                  fontWeight: FontWeight.w500,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: scale.s(14),
                                  vertical: scale.s(16),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      SizedBox(height: scale.s(10)),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: const Color(0xFFE53935),
                            fontSize: scale.s(13),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      l10n.contactSupport,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: OnboardingTheme.routeMeta,
                        fontSize: scale.s(13),
                      ),
                    ),
                    SizedBox(height: scale.s(16)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                scale.horizontalPadding,
                0,
                scale.horizontalPadding,
                scale.s(16),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _continue : null,
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
                    l10n.next,
                    style: TextStyle(
                      fontSize: scale.buttonFontSize,
                      fontWeight: FontWeight.w700,
                    ),
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
