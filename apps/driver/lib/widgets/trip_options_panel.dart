import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/crowd_level.dart';
import '../ui/driver_design.dart';

extension CrowdLevelIcons on CrowdLevel {
  IconData get icon => switch (this) {
        CrowdLevel.low => Icons.person_outline_rounded,
        CrowdLevel.medium => Icons.groups_2_outlined,
        CrowdLevel.high => Icons.groups_rounded,
      };
}

class TripOptionsPanel extends StatelessWidget {
  const TripOptionsPanel({
    super.key,
    required this.crowdLevel,
    required this.onCrowdLevelChanged,
    required this.onEndTrip,
    required this.onBreak,
    required this.onBreakLabel,
  });

  final CrowdLevel crowdLevel;
  final ValueChanged<CrowdLevel> onCrowdLevelChanged;
  final VoidCallback onEndTrip;
  final VoidCallback onBreak;
  final String onBreakLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.tripControls,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tripControlsHint,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 26),
          _SectionLabel(l10n.crowdLevel),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              children: [
                for (int index = 0; index < CrowdLevel.values.length; index++) ...[
                  _CrowdOption(
                    level: CrowdLevel.values[index],
                    selected: crowdLevel == CrowdLevel.values[index],
                    onTap: () => onCrowdLevelChanged(CrowdLevel.values[index]),
                  ),
                  if (index != CrowdLevel.values.length - 1)
                    const _CardDivider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SectionLabel(l10n.tripOptions),
          const SizedBox(height: 10),
          _SettingsCard(
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.stop_circle_outlined,
                  label: l10n.endTrip,
                  tint: const Color(0xFFA24E67),
                  onTap: onEndTrip,
                ),
                const _CardDivider(),
                _ActionRow(
                  icon: Icons.pause_circle_outline_rounded,
                  label: onBreakLabel,
                  onTap: onBreak,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.4),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

class _CrowdOption extends StatelessWidget {
  const _CrowdOption({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final CrowdLevel level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(level.icon, color: Colors.white70, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.crowdLevelLabel(level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.crowdLevelHint(level),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? DriverColors.orange : Colors.white54,
                    width: 1.4,
                  ),
                  color: selected
                      ? DriverColors.orange.withValues(alpha: 0.16)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: DriverColors.orange,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: tint ?? Colors.white70, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: tint ?? Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DriverChevronForward(
                color: Colors.white.withValues(alpha: 0.45),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
