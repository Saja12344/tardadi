import 'package:flutter/material.dart';

import '../models/route_list_item.dart';
import '../services/user_session.dart';

class AppLocalizations {
  AppLocalizations(this.language);

  final AppLanguage language;

  bool get isArabic => language == AppLanguage.arabic;

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Locale get locale => isArabic ? const Locale('ar') : const Locale('en');

  static AppLocalizations of(BuildContext context) {
    return AppLocaleScope.of(context);
  }

  String get appName => isArabic ? 'ترددي' : 'Tardadi';

  String get next => isArabic ? 'التالي' : 'Next';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get verify => isArabic ? 'تحقق' : 'Verify';
  String get onboardingStepPlan => isArabic ? '٠١ · خطّط' : '01 · PLAN';

  String get onboardingStepLocate => isArabic ? '٠٢ · موقعك' : '02 · LOCATE';

  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get settingsSubtitle => isArabic
      ? 'خصّص اللغة ونوع الحساب'
      : 'Customize language and account mode';
  String get languageTitle => isArabic ? 'اللغة' : 'Language';
  String get mode => isArabic ? 'الوضع' : 'Mode';
  String get business => isArabic ? 'أعمال' : 'Business';
  String get publicMode => isArabic ? 'عام' : 'Public';
  String get eng => 'Eng';
  String get ar => 'Ar';

  String get onboardingTagline =>
      isArabic ? 'وصل بدون تخمين' : 'GET THERE WITH LESS GUESSWORK';

  String get onboardingTitle1 =>
      isArabic ? 'خطّط رحلتك بوضوح' : 'Plan your trip clearly';

  String get onboardingSubtitle1 => isArabic
      ? 'شوف المسار والمحطات على الخريطة قبل ما تطلع.'
      : 'See the route and stops on the map before you leave.';

  String get onboardingTitle2 =>
      isArabic ? 'المحطات حولك مباشرة' : 'Stops around you, instantly';

  String get onboardingSubtitle2 => isArabic
      ? 'فعّل الموقع عشان نعرض أقرب المحطات من مكانك.'
      : 'Enable location so we can show the nearest stops to you.';

  String get allowLocation =>
      isArabic ? 'تفعيل الموقع' : 'Enable location';

  String get accountTypeTitle =>
      isArabic ? 'كيف ستستخدم التطبيق؟' : 'How will you use the application?';

  String get accountTypeSubtitle => isArabic
      ? 'اختر نوع حسابك للمتابعة'
      : 'Choose your account type to continue';

  String get personal => isArabic ? 'شخصي' : 'Personal';

  String get personalSubtitle => isArabic
      ? 'للأفراد والاستخدام الشخصي اليومي'
      : 'For individuals and everyday personal use';

  String get businessSubtitle => isArabic
      ? 'للمنظمات والشركات المسجلة فقط'
      : 'For registered organizations and companies only';

  String get businessNote => isArabic
      ? 'الوصول للأعمال متاح للمنظمات المسجلة فقط'
      : 'Business access is available for registered organizations only';

  String get verifyYourNumber =>
      isArabic ? 'تحقق من رقمك' : 'Verify Your Number';

  String get verifyPhoneTitle =>
      isArabic ? 'تحقق من رقم هاتفك' : 'Verify Your Phone Number';

  String get verifyPhoneSubtitle => isArabic
      ? 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى هاتفك'
      : 'Enter the 6-digit code sent to your phone';

  String get verifyNumberSubtitle => isArabic
      ? 'يتم التحقق فقط من الأرقام المسجلة في قاعدة البيانات'
      : 'Only numbers registered in the database can be verified';

  String get phoneNumber => isArabic ? 'رقم الجوال' : 'Phone number';
  String get phonePlaceholder =>
      isArabic ? 'أدخل رقم جوالك' : 'Enter your phone number';
  String get invalidPhone =>
      isArabic ? 'أدخل رقم جوال صحيح' : 'Enter a valid phone number';
  String get contactSupport =>
      isArabic ? 'تحتاج مساعدة؟ تواصل مع الدعم' : 'Need help? Contact support';

  String get didntReceiveCode =>
      isArabic ? 'لم يصلك الرمز؟ ' : "Didn't receive the code? ";

  String resendIn(String timer) =>
      isArabic ? 'إعادة الإرسال خلال $timer' : 'Resend in $timer';

  String get resendCode => isArabic ? 'إعادة إرسال الرمز' : 'Resend Code';

  String get stationSearchHint =>
      isArabic ? 'اسم المحطة' : 'Station name';

  String get noRoutesFound =>
      isArabic ? 'لا توجد مسارات' : 'No routes found';

  String get publicSection => isArabic ? 'عام' : 'Public';

  String minutesLabel(int minutes) => isArabic
      ? (minutes == 1 ? 'دقيقة واحدة' : '$minutes دقائق')
      : (minutes == 1 ? '1 min' : '$minutes min');

  String minutesUnit(int minutes) =>
      isArabic ? (minutes == 1 ? 'دقيقة' : 'دقائق') : 'min';

  String get crowdingTitle => isArabic ? 'الازدحام' : 'Crowding';

  String routeStopTitle(String routeName, String stopLabel) {
    final name = localizeRouteName(routeName);
    return '$name - $stopLabel';
  }

  String localizeRouteName(String name) {
    if (!isArabic) return name;

    return switch (name.toLowerCase()) {
      'diriyah' => 'الدرعية',
      'roshan' => 'روشن',
      'avindar' => 'أفندار',
      'tkaful alrajhin' => 'تكافل الراجحي',
      _ => name,
    };
  }

  bool routeNameMatchesQuery(String routeName, String query) {
    if (query.isEmpty) return true;
    final normalized = query.toLowerCase();
    return routeName.toLowerCase().contains(normalized) ||
        localizeRouteName(routeName).toLowerCase().contains(normalized);
  }

  String vehicleLabel(VehicleType type, String fallbackName) {
    return switch (type) {
      VehicleType.golfCar => isArabic ? 'عربة جولف' : 'Golf car',
      VehicleType.vanCar => isArabic ? 'فان' : 'Van car',
      VehicleType.bus => fallbackName.startsWith('Bus')
          ? (isArabic
              ? fallbackName.replaceFirst('Bus', 'باص ')
              : fallbackName)
          : (isArabic ? 'باص' : fallbackName),
    };
  }

  String crowdingLabel(String value) {
    return switch (value.toLowerCase()) {
      'low' => isArabic ? 'فاضي' : 'Quiet',
      'medium' => isArabic ? 'متوسط' : 'Moderate',
      'high' => isArabic ? 'ممتلئ' : 'Crowded',
      _ => value,
    };
  }

  String localizeMetaLabel(String value) {
    if (value.contains('Every') && value.contains('min')) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      final minutes = match?.group(1) ?? '5';
      return isArabic ? 'كل $minutes دقائق' : value;
    }
    if (value.contains('Buses')) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      final count = match?.group(1) ?? '0';
      return isArabic ? '$count باص' : value;
    }
    if (value.contains('Stations')) {
      final match = RegExp(r'(\d+)').firstMatch(value);
      final count = match?.group(1) ?? '0';
      return isArabic ? '$count محطة' : value;
    }
    return value;
  }

  String notificationsOn(String busName) =>
      isArabic ? 'تم تفعيل التنبيهات لـ $busName' : 'Notifications on for $busName';

  String notificationsOff(String busName) =>
      isArabic ? 'تم إيقاف التنبيهات لـ $busName' : 'Notifications off for $busName';

  String busArrived(String busName) => isArabic
      ? 'وصل $busName إلى محطتك'
      : '$busName has arrived at your stop';

  String busMinutesAway(String busName, int minutes) => isArabic
      ? '$busName على بعد $minutes د'
      : '$busName is $minutes min away';

  String get notificationsPermissionDenied => isArabic
      ? 'فعّل الإشعارات من إعدادات الجهاز لتلقي تنبيهات الباص'
      : 'Enable notifications in device settings to get bus alerts';
}

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    super.key,
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  static AppLocalizations of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in widget tree');
    return scope!.localizations;
  }

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) {
    return oldWidget.localizations.language != localizations.language;
  }
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
