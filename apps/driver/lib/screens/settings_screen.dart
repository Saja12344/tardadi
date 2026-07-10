import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../l10n/app_localizations.dart';
import '../services/driver_prefs.dart';
import '../utils/arabic_display.dart';
import '../services/locale_notifier.dart';
import '../services/session_store.dart';
import '../ui/driver_design.dart';
import 'map_screen.dart';

const kVehicleOptions = ['Bus', 'Golf car', 'Van', 'Private car'];

const _vehicleAssets = <String, String>{
  'Bus': DriverAssets.vehicleBus,
  'Golf car': DriverAssets.vehicleGolf,
  'Van': DriverAssets.vehicleVan,
  'Private car': DriverAssets.vehicleCar,
};

String _displayDriverName(BuildContext context, DriverSession session) {
  final name = session.driver.name.trim();
  if (name.isEmpty) {
    return context.displayPersonName('Ahmed Al-Rashid');
  }
  return context.displayPersonName(name, nameAr: session.driver.nameAr);
}

String _driverInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'AK';
  if (parts.length == 1) {
    final first = parts.first;
    return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _routeSummary(BuildContext context, DriverSession session) {
  final bus = session.bus.label.trim();
  final route = context.displayPlaceName(
    session.route.name.trim(),
    nameAr: session.route.nameAr,
  );
  final pieces = [if (bus.isNotEmpty) bus, if (route.isNotEmpty) route];
  return pieces.isEmpty ? 'Track · Yellow' : pieces.join(' · ');
}

/// First login only — grid picker (Chose.png).
class VehicleOnboardingScreen extends StatefulWidget {
  const VehicleOnboardingScreen({super.key});

  @override
  State<VehicleOnboardingScreen> createState() => _VehicleOnboardingScreenState();
}

class _VehicleOnboardingScreenState extends State<VehicleOnboardingScreen> {
  String? _selected;

  Future<void> _continue() async {
    final selected = _selected;
    if (selected == null) return;

    final session = SessionStore.instance.session;
    if (session == null) return;

    final driverKey = DriverPrefs.driverKey(
      phone: session.driver.phone,
      driverId: session.driver.driverId,
    );
    await DriverPrefs.instance.saveVehicleSetup(
      driverKey: driverKey,
      vehicle: selected,
    );
    SessionStore.instance.setVehicle(selected);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      driverRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final canContinue = _selected != null;

    return DriverChrome(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32, top + 40, 32, bottom + 20),
        child: Column(
          children: [
            Image.asset(DriverAssets.mark, width: 80, fit: BoxFit.contain),
            const SizedBox(height: 32),
            Text(
              l10n.chooseVehicle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.02,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final vehicle in kVehicleOptions)
                    _VehicleGridCard(
                      label: context.l10n.vehicleLabel(vehicle),
                      selected: _selected == vehicle,
                      onTap: () => setState(() => _selected = vehicle),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            DriverButton(
              label: l10n.next,
              onPressed: canContinue ? _continue : null,
              color: canContinue ? DriverColors.orange : DriverColors.card,
              height: 56,
              fontSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleGridCard extends StatelessWidget {
  const _VehicleGridCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DriverColors.orange : DriverColors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _VehicleAssetIcon(vehicle: label),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleAssetIcon extends StatelessWidget {
  const _VehicleAssetIcon({
    required this.vehicle,
    this.iconBoxHeight = 54,
    this.iconBoxWidth = 84,
  });

  final String vehicle;
  final double iconBoxHeight;
  final double iconBoxWidth;

  @override
  Widget build(BuildContext context) {
    final asset = _vehicleAssets[vehicle];
    if (asset == null) return const SizedBox.shrink();
    return SizedBox(
      width: iconBoxWidth,
      height: iconBoxHeight,
      child: Center(
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          width: iconBoxWidth,
          height: iconBoxHeight,
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.session,
    required this.selectedVehicle,
    required this.onVehicleChanged,
    required this.onLogout,
  });

  final DriverSession session;
  final String selectedVehicle;
  final ValueChanged<String> onVehicleChanged;
  final VoidCallback onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _vehicle = widget.selectedVehicle;
  bool _notifications = false;
  late bool _savedEnglish = !LocaleNotifier.instance.isArabic;
  late bool _pendingEnglish = _savedEnglish;

  bool get _languageDirty => _pendingEnglish != _savedEnglish;

  Future<void> _saveLanguage() async {
    final locale = _pendingEnglish ? const Locale('en') : const Locale('ar');
    await LocaleNotifier.instance.setLocale(locale);
    if (!mounted) return;
    setState(() => _savedEnglish = _pendingEnglish);
    DriverSnack.show(context, context.l10n.languageSaved);
  }

  Future<void> _changeVehicle() async {
    final next = await Navigator.of(context).push<String>(
      driverRoute(
        builder: (_) => ChangeVehicleScreen(selectedVehicle: _vehicle),
      ),
    );
    if (next == null) return;
    setState(() => _vehicle = next);
    widget.onVehicleChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = _displayDriverName(context, widget.session);
    final routeSummary = _routeSummary(context, widget.session);

    return DriverSidePanel(
      onClose: () => Navigator.pop(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 60,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DriverProfileHeader(
                      name: displayName,
                      subtitle: routeSummary,
                    ),
                    const SizedBox(height: 26),
                    _SectionLabel(l10n.preferences),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      child: Column(
                        children: [
                          _SettingRow(
                            icon: Icons.language_rounded,
                            label: l10n.language,
                            trailing: _SegmentToggle(
                              left: 'Eng',
                              right: 'Ar',
                              leftSelected: _pendingEnglish,
                              onChanged: (value) =>
                                  setState(() => _pendingEnglish = value),
                            ),
                          ),
                          const _CardDivider(),
                          _SettingRow(
                            icon: Icons.notifications_none_rounded,
                            label: l10n.notifications,
                            trailing: _SwitchPill(
                              value: _notifications,
                              onChanged: (value) =>
                                  setState(() => _notifications = value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_languageDirty) ...[
                      const SizedBox(height: 12),
                      DriverButton(
                        label: l10n.save,
                        onPressed: _saveLanguage,
                        height: 48,
                        fontSize: 17,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _SectionLabel(l10n.vehicle),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _changeVehicle,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                _VehicleAssetIcon(
                                  vehicle: _vehicle,
                                  iconBoxWidth: 22,
                                  iconBoxHeight: 15,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    l10n.changeVehicle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.vehicleLabel(_vehicle),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.45),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    const SizedBox(width: 4),
                                    DriverChevronForward(
                                      color: const Color(0x73FFFFFF),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: widget.onLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white.withValues(alpha: 0.9),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.logOut),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChangeVehicleScreen extends StatefulWidget {
  const ChangeVehicleScreen({super.key, required this.selectedVehicle});

  final String selectedVehicle;

  @override
  State<ChangeVehicleScreen> createState() => _ChangeVehicleScreenState();
}

class _ChangeVehicleScreenState extends State<ChangeVehicleScreen> {
  late String _selected = widget.selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DriverSidePanel(
      onClose: () => Navigator.pop(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 58,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.changeVehicle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.selectAssignedVehicle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0x8CFFFFFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _SettingsCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _VehicleAssetIcon(
                              vehicle: _selected,
                              iconBoxWidth: 48,
                              iconBoxHeight: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.vehicleLabel(_selected),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.currentAssignedVehicle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel(l10n.availableVehicles),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      child: Column(
                        children: [
                          for (int index = 0; index < kVehicleOptions.length; index++) ...[
                            _VehicleOption(
                              label: l10n.vehicleLabel(kVehicleOptions[index]),
                              selected: _selected == kVehicleOptions[index],
                              onTap: () =>
                                  setState(() => _selected = kVehicleOptions[index]),
                            ),
                            if (index != kVehicleOptions.length - 1)
                              const _CardDivider(),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    DriverButton(
                      label: l10n.saveChanges,
                      color: DriverColors.orange,
                      onPressed: () => Navigator.pop(context, _selected),
                      height: 54,
                      fontSize: 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

class _DriverProfileHeader extends StatelessWidget {
  const _DriverProfileHeader({
    required this.name,
    required this.subtitle,
  });

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: DriverColors.orange,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            _driverInitials(name),
            style: const TextStyle(
              color: Color(0xFF4A1B0C),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.directions_bus_outlined,
                    size: 15,
                    color: Color(0x8CFFFFFF),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _VehicleOption extends StatelessWidget {
  const _VehicleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
              _VehicleAssetIcon(
                vehicle: label,
                iconBoxWidth: 48,
                iconBoxHeight: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0x99FFFFFF),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}

class _SegmentToggle extends StatelessWidget {
  const _SegmentToggle({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onChanged,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _TogglePart(
            label: left,
            selected: leftSelected,
            onTap: () => onChanged(true),
          ),
          _TogglePart(
            label: right,
            selected: !leftSelected,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _TogglePart extends StatelessWidget {
  const _TogglePart({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? DriverColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchPill extends StatelessWidget {
  const _SwitchPill({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? DriverColors.orange.withValues(alpha: 0.26)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Align(
          alignment: value
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? DriverColors.orange : Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}
