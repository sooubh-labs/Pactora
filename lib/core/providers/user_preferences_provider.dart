import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String profileImagePath;
  final String currencySymbol;
  final String currencyCode;
  final bool isLifetimePremium;
  final DateTime? premiumExpiryDate;
  final int promisesAddedCount;
  final int promiseLimit;

  UserPreferences({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.profileImagePath,
    required this.currencySymbol,
    required this.currencyCode,
    required this.isLifetimePremium,
    this.premiumExpiryDate,
    required this.promisesAddedCount,
    required this.promiseLimit,
  });

  UserPreferences copyWith({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImagePath,
    String? currencySymbol,
    String? currencyCode,
    bool? isLifetimePremium,
    DateTime? premiumExpiryDate,
    int? promisesAddedCount,
    int? promiseLimit,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      isLifetimePremium: isLifetimePremium ?? this.isLifetimePremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      promisesAddedCount: promisesAddedCount ?? this.promisesAddedCount,
      promiseLimit: promiseLimit ?? this.promiseLimit,
    );
  }
}

class UserPreferencesNotifier extends Notifier<UserPreferences> {
  static const _keyName = 'profile_name';
  static const _keyEmail = 'profile_email';
  static const _keyPhone = 'profile_phone';
  static const _keyBio = 'profile_bio';
  static const _keyImage = 'profile_image';
  static const _keyCurrencySymbol = 'currency_symbol';
  static const _keyCurrencyCode = 'currency_code';
  static const _keyIsLifetime = 'is_lifetime_premium';
  static const _keyExpiryDate = 'premium_expiry_date';
  static const _keyPromisesAdded = 'promises_added_count';
  static const _keyPromiseLimit = 'promise_limit';

  @override
  UserPreferences build() {
    _loadFromPrefs();
    return UserPreferences(
      name: 'User Name',
      email: 'user@example.com',
      phone: '',
      bio: '',
      profileImagePath: '',
      currencySymbol: '₹',
      currencyCode: 'INR',
      isLifetimePremium: false,
      premiumExpiryDate: null,
      promisesAddedCount: 0,
      promiseLimit: 10,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_keyExpiryDate);
    state = UserPreferences(
      name: prefs.getString(_keyName) ?? 'User Name',
      email: prefs.getString(_keyEmail) ?? 'user@example.com',
      phone: prefs.getString(_keyPhone) ?? '',
      bio: prefs.getString(_keyBio) ?? '',
      profileImagePath: prefs.getString(_keyImage) ?? '',
      currencySymbol: prefs.getString(_keyCurrencySymbol) ?? '₹',
      currencyCode: prefs.getString(_keyCurrencyCode) ?? 'INR',
      isLifetimePremium: prefs.getBool(_keyIsLifetime) ?? false,
      premiumExpiryDate: expiryStr != null ? DateTime.tryParse(expiryStr) : null,
      promisesAddedCount: prefs.getInt(_keyPromisesAdded) ?? 0,
      promiseLimit: prefs.getInt(_keyPromiseLimit) ?? 10,
    );
  }

  Future<void> setLifetimePremium(bool isLifetime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLifetime, isLifetime);
    state = state.copyWith(isLifetimePremium: isLifetime);
  }

  Future<void> setPremiumExpiry(DateTime expiryDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyExpiryDate, expiryDate.toIso8601String());
    state = state.copyWith(premiumExpiryDate: expiryDate);
  }

  Future<void> incrementPromisesAdded() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = state.promisesAddedCount + 1;
    await prefs.setInt(_keyPromisesAdded, newCount);
    state = state.copyWith(promisesAddedCount: newCount);
  }

  Future<void> increasePromiseLimit(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final newLimit = state.promiseLimit + amount;
    await prefs.setInt(_keyPromiseLimit, newLimit);
    state = state.copyWith(promiseLimit: newLimit);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString(_keyName, name);
    if (email != null) await prefs.setString(_keyEmail, email);
    if (phone != null) await prefs.setString(_keyPhone, phone);
    if (bio != null) await prefs.setString(_keyBio, bio);
    if (profileImagePath != null) await prefs.setString(_keyImage, profileImagePath);

    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      profileImagePath: profileImagePath,
    );
  }

  Future<void> updateCurrency(String symbol, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrencySymbol, symbol);
    await prefs.setString(_keyCurrencyCode, code);

    state = state.copyWith(
      currencySymbol: symbol,
      currencyCode: code,
    );
  }
}

final userPreferencesProvider = NotifierProvider<UserPreferencesNotifier, UserPreferences>(() {
  return UserPreferencesNotifier();
});

final isPremiumProvider = Provider<bool>((ref) {
  final prefs = ref.watch(userPreferencesProvider);
  if (prefs.isLifetimePremium) return true;
  if (prefs.premiumExpiryDate != null && prefs.premiumExpiryDate!.isAfter(DateTime.now())) {
    return true;
  }
  return false;
});

class CurrencyOption {
  final String symbol;
  final String code;
  final String name;

  const CurrencyOption(this.symbol, this.code, this.name);
}

const List<CurrencyOption> currencyOptions = [
  CurrencyOption('₹', 'INR', 'Indian Rupee'),
  CurrencyOption('\$', 'USD', 'US Dollar'),
  CurrencyOption('€', 'EUR', 'Euro'),
  CurrencyOption('£', 'GBP', 'British Pound'),
  CurrencyOption('¥', 'JPY', 'Japanese Yen'),
  CurrencyOption('A\$', 'AUD', 'Australian Dollar'),
  CurrencyOption('C\$', 'CAD', 'Canadian Dollar'),
  CurrencyOption('CHF', 'CHF', 'Swiss Franc'),
  CurrencyOption('元', 'CNY', 'Chinese Yuan'),
  CurrencyOption('S\$', 'SGD', 'Singapore Dollar'),
];
