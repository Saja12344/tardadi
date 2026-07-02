import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../screens/enter_phone_screen.dart';
import '../services/user_session.dart';
import '../widgets/onboarding/onboarding_theme.dart';

class SettingsPopup extends StatefulWidget {
  const SettingsPopup({
    super.key,
    required this.onClose,
    required this.onChanged,
  });

  final VoidCallback onClose;
  final VoidCallback onChanged;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onChanged,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => SettingsPopup(
        onClose: () => Navigator.of(context).pop(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<SettingsPopup> createState() => _SettingsPopupState();
}

class _SettingsPopupState extends State<SettingsPopup> {
  late AppLanguage _language = UserSession.instance.language;
  late AccountType _mode =
      UserSession.instance.accountType ?? AccountType.personal;

  void _apply() {
    UserSession.instance.setLanguage(_language);
    UserSession.instance.setAccountType(_mode);
    widget.onChanged();

    final navigateToVerify = _mode == AccountType.business;
    final navigator = Navigator.of(context);
    navigator.pop();

    if (!navigateToVerify) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const EnterPhoneScreen(fromSettings: true),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF181B52),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: OnboardingTheme.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: OnboardingTheme.orange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.settings,
                    style: const TextStyle(
                      color: OnboardingTheme.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: OnboardingTheme.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 16),
            _SettingsRow(
              icon: Icons.translate_rounded,
              label: l10n.languageTitle,
              child: _SegmentToggle<AppLanguage>(
                values: const [AppLanguage.english, AppLanguage.arabic],
                labels: [l10n.eng, l10n.ar],
                selected: _language,
                onChanged: (value) {
                  setState(() => _language = value);
                  UserSession.instance.setLanguage(value);
                  widget.onChanged();
                },
              ),
            ),
            const SizedBox(height: 14),
            _SettingsRow(
              icon: Icons.swap_horiz_rounded,
              label: l10n.mode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: OnboardingTheme.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _ModeOption(
                      label: l10n.business,
                      selected: _mode == AccountType.business,
                      onTap: () =>
                          setState(() => _mode = AccountType.business),
                    ),
                    Divider(
                      height: 16,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    _ModeOption(
                      label: l10n.publicMode,
                      selected: _mode == AccountType.personal,
                      onTap: () =>
                          setState(() => _mode = AccountType.personal),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OnboardingTheme.orange,
                  foregroundColor: OnboardingTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: OnboardingTheme.orange),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: OnboardingTheme.muted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _SegmentToggle<T> extends StatelessWidget {
  const _SegmentToggle({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: OnboardingTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: selected == values[i]
                        ? OnboardingTheme.orange
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: selected == values[i]
                          ? OnboardingTheme.white
                          : OnboardingTheme.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? OnboardingTheme.orange
                      : OnboardingTheme.muted,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: OnboardingTheme.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? OnboardingTheme.white
                      : OnboardingTheme.white.withValues(alpha: 0.82),
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
