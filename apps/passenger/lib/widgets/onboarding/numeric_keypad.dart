import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.keyHeight,
    required this.keyFontSize,
    required this.onKeyTap,
  });

  final double keyHeight;
  final double keyFontSize;
  final ValueChanged<String> onKeyTap;

  static const _keyTextColor = Color(0xFF13154B);

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Container(
      color: const Color(0xFFF2F2F7),
      padding: EdgeInsets.fromLTRB(
        8,
        6,
        8,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        children: keys.map((row) {
          return Row(
            children: row.map((key) {
              if (key.isEmpty) {
                return Expanded(child: SizedBox(height: keyHeight));
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onKeyTap(key),
                      child: SizedBox(
                        height: keyHeight,
                        child: Center(
                          child: key == 'back'
                              ? Icon(
                                  Icons.backspace_outlined,
                                  size: keyFontSize,
                                  color: _keyTextColor,
                                )
                              : Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: keyFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: _keyTextColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
