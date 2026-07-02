import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/user_session.dart';
import '../widgets/onboarding/onboarding_primary_button.dart';
import '../widgets/onboarding/onboarding_scale.dart';
import '../widgets/onboarding/onboarding_theme.dart';
import '../widgets/onboarding/tardadi_logo.dart';
import '../widgets/route_card.dart';
import 'enter_phone_screen.dart';
import 'routes_main_screen.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  AccountType _selected = AccountType.personal;

  void _continue() {
    UserSession.instance.setAccountType(_selected);

    if (_selected == AccountType.personal) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const RoutesMainScreen()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EnterPhoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = OnboardingScale(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: scale.horizontalPadding,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: scale.s(28)),
                      TardadiLogoIcon(size: scale.accountLogoSize),
                      SizedBox(height: scale.s(24)),
                      Text(
                        l10n.accountTypeTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: OnboardingTheme.white,
                          fontSize: scale.s(24),
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: scale.s(10)),
                      Text(
                        l10n.accountTypeSubtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: OnboardingTheme.white.withValues(
                            alpha: 0.68,
                          ),
                          fontSize: scale.accountSubtitleSize,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: scale.s(36)),
                      AccountTypeOption(
                        icon: Icons.person_outline_rounded,
                        title: l10n.personal,
                        subtitle: l10n.personalSubtitle,
                        selected: _selected == AccountType.personal,
                        titleSize: scale.s(24),
                        subtitleSize: scale.s(14),
                        onTap: () => setState(
                          () => _selected = AccountType.personal,
                        ),
                      ),
                      AccountTypeOption(
                        icon: Icons.business_center_outlined,
                        title: l10n.business,
                        subtitle: l10n.businessSubtitle,
                        selected: _selected == AccountType.business,
                        titleSize: scale.s(24),
                        subtitleSize: scale.s(14),
                        onTap: () => setState(
                          () => _selected = AccountType.business,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: scale.s(12),
                  vertical: scale.s(10),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: scale.s(18),
                      color: OnboardingTheme.orange.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: scale.s(10)),
                    Expanded(
                      child: Text(
                        l10n.businessNote,
                        style: GoogleFonts.ubuntu(
                          color: OnboardingTheme.white.withValues(
                            alpha: 0.58,
                          ),
                          fontSize: scale.s(12),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: scale.s(18)),
              OnboardingPrimaryButton(
                scale: scale,
                label: l10n.next,
                onPressed: _continue,
              ),
              SizedBox(height: scale.s(24)),
            ],
          ),
        ),
      ),
    );
  }
}
