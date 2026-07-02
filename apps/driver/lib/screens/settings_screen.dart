import 'package:flutter/material.dart';
import 'package:tardadi_core/tardadi_core.dart';

import '../ui/driver_design.dart';

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
  bool _english = true;

  Future<void> _changeVehicle() async {
    final next = await Navigator.of(context).push<String>(
      driverRoute(
        beginOffset: const Offset(0.08, 0),
        builder: (_) => ChangeVehicleScreen(selectedVehicle: _vehicle),
      ),
    );
    if (next == null) return;
    setState(() => _vehicle = next);
    widget.onVehicleChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsFrame(
      menuAction: () => Navigator.pop(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 46, 22, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 70,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.session.driver.name.isEmpty
                          ? 'Ahmed Al-Rashid'
                          : widget.session.driver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_bus_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${widget.session.bus.label} • ${widget.session.route.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFF56579D)),
                    const SizedBox(height: 8),
                    const _SectionLabel('Preferences'),
                    const SizedBox(height: 16),
                    _SettingRow(
                      label: 'Language',
                      trailing: _SegmentToggle(
                        left: 'Eng',
                        right: 'Ar',
                        leftSelected: _english,
                        onChanged: (value) => setState(() => _english = value),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SettingRow(
                      label: 'Notifications',
                      trailing: _SwitchPill(
                        value: _notifications,
                        onChanged: (value) =>
                            setState(() => _notifications = value),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFF56579D)),
                    const SizedBox(height: 12),
                    const _SectionLabel('Vehicle'),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _changeVehicle,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Change vehicle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _vehicle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF56579D)),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
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

class _SettingsFrame extends StatelessWidget {
  const _SettingsFrame({required this.menuAction, required this.child});

  final VoidCallback menuAction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final railWidth = width < 390 ? 92.0 : 104.0;

    return Scaffold(
      backgroundColor: DriverColors.navyDeep,
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: railWidth,
              color: DriverColors.sideMenu,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 42),
              child: IconButton(
                onPressed: menuAction,
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            Expanded(
              child: Container(color: DriverColors.navyPanel, child: child),
            ),
          ],
        ),
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
  final _vehicles = const ['Golf car', 'Bus', 'Van', 'Private car'];

  @override
  Widget build(BuildContext context) {
    return _SettingsFrame(
      menuAction: () => Navigator.pop(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 50, 22, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 74,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Change vehicle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.only(left: 48),
                    child: Text(
                      'Select your assigned vehicle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF56579D)),
                  const SizedBox(height: 16),
                  for (final vehicle in _vehicles)
                    _VehicleOption(
                      label: vehicle,
                      selected: _selected == vehicle,
                      onTap: () => setState(() => _selected = vehicle),
                    ),
                  const SizedBox(height: 34),
                  Center(
                    child: SizedBox(
                      width: 184,
                      child: DriverButton(
                        label: 'Save',
                        color: DriverColors.orange,
                        onPressed: () => Navigator.pop(context, _selected),
                        height: 42,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ],
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
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w800,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? DriverColors.orange : Colors.white,
                  width: 1.4,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: DriverColors.orange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        trailing,
      ],
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
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF383889),
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
              fontSize: 12,
              fontWeight: FontWeight.w900,
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
      child: Container(
        width: 62,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF383889),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: value
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 24,
              decoration: BoxDecoration(
                color: value ? DriverColors.orange : Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (!value)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Off',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
