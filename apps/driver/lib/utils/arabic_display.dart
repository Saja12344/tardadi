import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Arabic display helpers for names and place labels (Fusha).
class ArabicDisplay {
  ArabicDisplay._();

  static final _arabicScript = RegExp(r'[\u0600-\u06FF\u0750-\u077F]');

  static bool containsArabic(String value) =>
      _arabicScript.hasMatch(value);

  /// Driver / person name for the current locale.
  static String personName(
    BuildContext context, {
    required String name,
    String? nameAr,
  }) {
    if (!AppLocalizations.of(context).isArabic) return name;
    final ar = nameAr?.trim();
    if (ar != null && ar.isNotEmpty) return ar;
    return _transliterateName(name.trim());
  }

  /// Route, stop, or place label for the current locale.
  static String placeName(
    BuildContext context, {
    required String name,
    String? nameAr,
  }) {
    if (!AppLocalizations.of(context).isArabic) return name;
    final ar = nameAr?.trim();
    if (ar != null && ar.isNotEmpty) return ar;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    if (containsArabic(trimmed)) return trimmed;
    return _translatePlaceWords(_transliterateName(trimmed));
  }

  static String _transliterateName(String latin) {
    if (latin.isEmpty) return latin;
    final lower = latin.toLowerCase();
    final known = _knownNames[lower];
    if (known != null) return known;

    final buffer = StringBuffer();
    var i = 0;
    while (i < lower.length) {
      if (lower[i] == ' ') {
        buffer.write(' ');
        i++;
        continue;
      }
      String? mapped;
      for (final entry in _digraphs.entries) {
        if (lower.startsWith(entry.key, i)) {
          mapped = entry.value;
          i += entry.key.length;
          break;
        }
      }
      if (mapped == null) {
        mapped = _letters[lower[i]] ?? lower[i];
        i++;
      }
      buffer.write(mapped);
    }
    return buffer.toString();
  }

  static String _translatePlaceWords(String value) {
    var result = ' $value ';
    for (final entry in _placeTerms.entries) {
      result = result.replaceAll(
        RegExp('\\b${RegExp.escape(entry.key)}\\b', caseSensitive: false),
        ' ${entry.value} ',
      );
    }
    return result.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}

const _knownNames = <String, String>{
  'shad': 'شاد',
  'saja': 'سجى',
  'saj': 'سجى',
  'ahmed': 'أحمد',
  'ahmad': 'أحمد',
  'mohammed': 'محمد',
  'mohammad': 'محمد',
  'mohamed': 'محمد',
  'khalid': 'خالد',
  'abdullah': 'عبدالله',
  'abdulrahman': 'عبدالرحمن',
  'fatima': 'فاطمة',
  'roshn': 'روشن',
  'riyadh': 'الرياض',
  'jeddah': 'جدة',
  'dammam': 'الدمام',
};

const _digraphs = <String, String>{
  'sh': 'ش',
  'ch': 'تش',
  'kh': 'خ',
  'gh': 'غ',
  'th': 'ث',
  'dh': 'ذ',
  'aa': 'ا',
  'ee': 'ي',
  'oo': 'و',
};

const _letters = <String, String>{
  'a': 'ا',
  'b': 'ب',
  'c': 'ك',
  'd': 'د',
  'e': 'ي',
  'f': 'ف',
  'g': 'ج',
  'h': 'ه',
  'i': 'ي',
  'j': 'ج',
  'k': 'ك',
  'l': 'ل',
  'm': 'م',
  'n': 'ن',
  'o': 'و',
  'p': 'ب',
  'q': 'ق',
  'r': 'ر',
  's': 'س',
  't': 'ت',
  'u': 'و',
  'v': 'ف',
  'w': 'و',
  'x': 'كس',
  'y': 'ي',
  'z': 'ز',
};

const _placeTerms = <String, String>{
  'station': 'محطة',
  'stop': 'محطة',
  'terminal': 'محطة',
  'street': 'شارع',
  'st': 'شارع',
  'road': 'طريق',
  'rd': 'طريق',
  'avenue': 'جادة',
  'ave': 'جادة',
  'boulevard': 'شارع',
  'blvd': 'شارع',
  'highway': 'طريق',
  'mall': 'مجمع تجاري',
  'center': 'مركز',
  'centre': 'مركز',
  'university': 'جامعة',
  'college': 'كلية',
  'hospital': 'مستشفى',
  'airport': 'مطار',
  'park': 'حديقة',
  'mosque': 'مسجد',
  'school': 'مدرسة',
  'king': 'الملك',
  'prince': 'الأمير',
  'princess': 'الأميرة',
  'queen': 'الملكة',
  'north': 'شمال',
  'south': 'جنوب',
  'east': 'شرق',
  'west': 'غرب',
};

extension ArabicDisplayContext on BuildContext {
  String displayPersonName(String name, {String? nameAr}) =>
      ArabicDisplay.personName(this, name: name, nameAr: nameAr);

  String displayPlaceName(String name, {String? nameAr}) =>
      ArabicDisplay.placeName(this, name: name, nameAr: nameAr);
}
