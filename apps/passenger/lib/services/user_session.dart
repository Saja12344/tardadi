import 'package:flutter/foundation.dart';

enum AccountType { personal, business }

enum AppLanguage { english, arabic }

class UserSession extends ChangeNotifier {
  UserSession._();

  static final UserSession instance = UserSession._();

  AccountType? accountType;
  AppLanguage language = AppLanguage.english;
  String? phoneNumber;
  String? organizationName;

  void setAccountType(AccountType type) {
    accountType = type;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    this.language = language;
    notifyListeners();
  }

  void setPhoneNumber(String phone) => phoneNumber = phone;

  void setOrganizationName(String name) => organizationName = name;

  bool get isBusiness => accountType == AccountType.business;

  bool get isArabic => language == AppLanguage.arabic;
}
