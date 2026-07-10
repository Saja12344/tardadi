import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../models/crowd_level.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'AppLocalizations not found');
    return result!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Tardadi — Driver',
      'preferences': 'Preferences',
      'language': 'Language',
      'notifications': 'Notifications',
      'vehicle': 'Vehicle',
      'changeVehicle': 'Change vehicle',
      'logOut': 'Log out',
      'save': 'Save',
      'languageSaved': 'Language updated',
      'chooseVehicle': 'Choose Your vehicle',
      'next': 'Next',
      'selectAssignedVehicle': 'Select your assigned vehicle',
      'currentAssignedVehicle': 'Current assigned vehicle',
      'availableVehicles': 'Available vehicles',
      'saveChanges': 'Save changes',
      'verifyYourNumber': 'Verify Your Number',
      'onlyRegisteredNumbers': 'Only numbers registered in the database can be verified',
      'phoneNumber': 'Phone number',
      'needHelp': 'Need help? Contact support',
      'enterPhoneNumber': 'Enter your phone number',
      'enterPhone': 'Enter your phone number',
      'verifyYourPhoneNumber': 'Verify Your Phone Number',
      'enterSixDigitCode': 'Enter the 6-digit code sent to your phone',
      'didntReceiveCode': 'Didn’t receive the code? ',
      'resendCode': 'Resend Code',
      'resendIn': 'Resend in 00:{seconds}',
      'verifying': 'Verifying...',
      'verify': 'Verify',
      'codeResent': 'A new code was sent',
      'enterOtp': 'Enter the 6-digit verification code',
      'demoOtpHint': 'Temporary verification code is 000000',
      'tardadi': 'Tardadi',
      'distanceFromStart': 'Your distance from starting point',
      'start': 'Start',
      'youCanStart': 'You can start',
      'goCloserToStart': 'Go closer to start',
      'lastGps': 'Last GPS: {gps} • {route} • {vehicle}',
      'offRoute': 'Off route — returning to line',
      'endTripTitle': 'End trip?',
      'endTripMessage':
          'Are you sure you want to end this trip? This action will stop live tracking.',
      'cancel': 'Cancel',
      'endTrip': 'End Trip',
      'breakStarted': 'Break started',
      'tripResumed': 'Trip resumed',
      'returnRouteStarted': 'Return route started',
      'takeABreak': 'Take a Break',
      'resumeTrip': 'Resume Trip',
      'tripControls': 'Trip controls',
      'tripControlsHint': 'Update crowd level and manage the active trip',
      'crowdLevel': 'Crowd level',
      'tripOptions': 'Trip options',
      'crowdEmpty': 'Empty',
      'crowdModerate': 'Moderate',
      'crowdCrowded': 'Crowded',
      'crowdEmptyHint': 'Few passengers on board',
      'crowdModerateHint': 'Comfortable occupancy',
      'crowdCrowdedHint': 'Bus is getting full',
      'onBreak': 'On break',
      'minutesEta': '{minutes} minutes',
      'tripPaused': 'Trip paused temporarily',
      'estimatedArrival': 'Estimated Time of Arrival',
      'arrived': 'Arrived',
      'confirmed': 'Confirmed',
      'mapStart': 'Start',
      'mapEnd': 'End',
      'cannotStartTrip':
          'Cannot start the trip now. Move closer to the starting point ({distance} remaining).',
      'vehicleBus': 'Bus',
      'vehicleGolf': 'Golf car',
      'vehicleVan': 'Van',
      'vehicleCar': 'Private car',
      'meters': '{value} m',
      'kilometers': '{value} km',
    },
    'ar': {
      'appTitle': 'ترددي — سائق',
      'preferences': 'التفضيلات',
      'language': 'اللغة',
      'notifications': 'التنبيهات',
      'vehicle': 'المركبة',
      'changeVehicle': 'تغيير المركبة',
      'logOut': 'تسجيل الخروج',
      'save': 'حفظ',
      'languageSaved': 'تم تحديث اللغة',
      'chooseVehicle': 'اختر مركبتك',
      'next': 'التالي',
      'selectAssignedVehicle': 'اختر المركبة المعيّنة لك',
      'currentAssignedVehicle': 'المركبة المعيّنة حالياً',
      'availableVehicles': 'المركبات المتاحة',
      'saveChanges': 'حفظ التغييرات',
      'verifyYourNumber': 'تحقق من رقمك',
      'onlyRegisteredNumbers': 'يُقبل فقط الأرقام المسجّلة في قاعدة البيانات',
      'phoneNumber': 'رقم الجوال',
      'needHelp': 'تحتاج مساعدة؟ تواصل مع الدعم',
      'enterPhoneNumber': 'أدخل رقم جوالك',
      'enterPhone': 'أدخل رقم الجوال',
      'verifyYourPhoneNumber': 'تحقق من رقم جوالك',
      'enterSixDigitCode': 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى جوالك',
      'didntReceiveCode': 'لم يصلك الرمز؟ ',
      'resendCode': 'إعادة إرسال الرمز',
      'resendIn': 'إعادة الإرسال خلال 00:{seconds}',
      'verifying': 'جاري التحقق...',
      'verify': 'تحقق',
      'codeResent': 'تم إرسال رمز جديد',
      'enterOtp': 'أدخل رمز التحقق المكوّن من 6 أرقام',
      'demoOtpHint': 'رمز التحقق المؤقت هو 000000',
      'tardadi': 'ترددي',
      'start': 'ابدأ',
      'youCanStart': 'يمكنك البدء',
      'goCloserToStart': 'اقترب من نقطة الانطلاق',
      'distanceFromStart': 'المسافة من نقطة الانطلاق',
      'lastGps': 'آخر GPS: {gps} • {route} • {vehicle}',
      'offRoute': 'خارج المسار — عُدْ إلى الخط',
      'endTripTitle': 'إنهاء الرحلة؟',
      'endTripMessage':
          'هل أنت متأكّد من إنهاء هذه الرحلة؟ سيتوقّف التتبّع المباشر.',
      'cancel': 'إلغاء',
      'endTrip': 'إنهاء الرحلة',
      'breakStarted': 'بدأت الاستراحة',
      'tripResumed': 'استُؤنفت الرحلة',
      'returnRouteStarted': 'بدأ مسار العودة',
      'takeABreak': 'أخِذ استراحةً',
      'resumeTrip': 'استئناف الرحلة',
      'tripControls': 'التحكّم بالرحلة',
      'tripControlsHint': 'حدّث مستوى الازدحام وأدِر الرحلة النشطة',
      'crowdLevel': 'مستوى الازدحام',
      'tripOptions': 'خيارات الرحلة',
      'crowdEmpty': 'خفيف',
      'crowdModerate': 'متوسط',
      'crowdCrowded': 'مزدحم',
      'crowdEmptyHint': 'عددٌ قليلٌ من الركاب',
      'crowdModerateHint': 'إشغالٌ مريح',
      'crowdCrowdedHint': 'ازدحامٌ متزايد',
      'onBreak': 'في استراحة',
      'minutesEta': '{minutes} دقيقة',
      'tripPaused': 'الرحلة متوقّفة مؤقّتاً',
      'estimatedArrival': 'الوقت المتوقّع للوصول',
      'arrived': 'تأكيد الوصول',
      'confirmed': 'تم التأكيد',
      'mapStart': 'نقطة الانطلاق',
      'mapEnd': 'نقطة الوصول',
      'cannotStartTrip':
          'لا يمكن بدء الرحلة الآن. اقترب من نقطة الانطلاق ({distance} متبقية).',
      'vehicleBus': 'حافلة',
      'vehicleGolf': 'عربة غولف',
      'vehicleVan': 'فان',
      'vehicleCar': 'سيارة خاصة',
      'meters': '{value} م',
      'kilometers': '{value} كم',
    },
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _strings[lang]?[key] ?? _strings['en']![key] ?? key;
  }

  String format(String key, Map<String, String> params) {
    var value = _t(key);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  String get appTitle => _t('appTitle');
  String get preferences => _t('preferences');
  String get language => _t('language');
  String get notifications => _t('notifications');
  String get vehicle => _t('vehicle');
  String get changeVehicle => _t('changeVehicle');
  String get logOut => _t('logOut');
  String get save => _t('save');
  String get languageSaved => _t('languageSaved');
  String get chooseVehicle => _t('chooseVehicle');
  String get next => _t('next');
  String get selectAssignedVehicle => _t('selectAssignedVehicle');
  String get currentAssignedVehicle => _t('currentAssignedVehicle');
  String get availableVehicles => _t('availableVehicles');
  String get saveChanges => _t('saveChanges');
  String get verifyYourNumber => _t('verifyYourNumber');
  String get onlyRegisteredNumbers => _t('onlyRegisteredNumbers');
  String get phoneNumber => _t('phoneNumber');
  String get needHelp => _t('needHelp');
  String get enterPhoneNumber => _t('enterPhoneNumber');
  String get enterPhone => _t('enterPhone');
  String get verifyYourPhoneNumber => _t('verifyYourPhoneNumber');
  String get enterSixDigitCode => _t('enterSixDigitCode');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get resendCode => _t('resendCode');
  String resendIn(String seconds) => format('resendIn', {'seconds': seconds});
  String get verifying => _t('verifying');
  String get verify => _t('verify');
  String get codeResent => _t('codeResent');
  String get enterOtp => _t('enterOtp');
  String get demoOtpHint => _t('demoOtpHint');
  String get tardadi => _t('tardadi');
  String get distanceFromStart => _t('distanceFromStart');
  String get start => _t('start');
  String get youCanStart => _t('youCanStart');
  String get goCloserToStart => _t('goCloserToStart');
  String lastGps({
    required String gps,
    required String route,
    required String vehicle,
  }) =>
      format('lastGps', {'gps': gps, 'route': route, 'vehicle': vehicle});
  String get offRoute => _t('offRoute');
  String get endTripTitle => _t('endTripTitle');
  String get endTripMessage => _t('endTripMessage');
  String get cancel => _t('cancel');
  String get endTrip => _t('endTrip');
  String get breakStarted => _t('breakStarted');
  String get tripResumed => _t('tripResumed');
  String get returnRouteStarted => _t('returnRouteStarted');
  String get takeABreak => _t('takeABreak');
  String get resumeTrip => _t('resumeTrip');
  String get tripControls => _t('tripControls');
  String get tripControlsHint => _t('tripControlsHint');
  String get crowdLevel => _t('crowdLevel');
  String get tripOptions => _t('tripOptions');
  String get onBreak => _t('onBreak');
  String minutesEta(int minutes) => format('minutesEta', {'minutes': '$minutes'});
  String get tripPaused => _t('tripPaused');
  String get estimatedArrival => _t('estimatedArrival');
  String get arrived => _t('arrived');
  String get confirmed => _t('confirmed');
  String get mapStart => _t('mapStart');
  String get mapEnd => _t('mapEnd');
  String cannotStartTrip(String distance) =>
      format('cannotStartTrip', {'distance': distance});
  String meters(num value) => format('meters', {'value': '${value.round()}'});
  String kilometers(num value) =>
      format('kilometers', {'value': '${value.round()}'});

  String vehicleLabel(String vehicleKey) => switch (vehicleKey) {
        'Bus' => _t('vehicleBus'),
        'Golf car' => _t('vehicleGolf'),
        'Van' => _t('vehicleVan'),
        'Private car' => _t('vehicleCar'),
        _ => vehicleKey,
      };

  String crowdLevelLabel(CrowdLevel level) => switch (level) {
        CrowdLevel.low => _t('crowdEmpty'),
        CrowdLevel.medium => _t('crowdModerate'),
        CrowdLevel.high => _t('crowdCrowded'),
      };

  String crowdLevelHint(CrowdLevel level) => switch (level) {
        CrowdLevel.low => _t('crowdEmptyHint'),
        CrowdLevel.medium => _t('crowdModerateHint'),
        CrowdLevel.high => _t('crowdCrowdedHint'),
      };

  String formatDistanceKm(double kilometers) {
    if (kilometers < 1) {
      return meters(kilometers * 1000);
    }
    return this.kilometers(kilometers);
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
