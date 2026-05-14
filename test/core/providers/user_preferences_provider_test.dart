import 'package:flutter_test/flutter_test.dart';
import 'package:pactora/core/providers/user_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserPreferences', () {
    test('copyWith works correctly', () {
      final prefs = UserPreferences(
        name: 'Test',
        email: 'test@example.com',
        phone: '123',
        bio: 'bio',
        profileImagePath: 'path',
        currencySymbol: '₹',
        currencyCode: 'INR',
        isLifetimePremium: false,
        promisesAddedCount: 0,
        promiseLimit: 10,
        themeMode: AppThemeMode.system,
      );

      final updated = prefs.copyWith(themeMode: AppThemeMode.dark);
      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.name, 'Test');
    });
  });

  group('UserPreferencesNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default themeMode system', () {
      final prefs = container.read(userPreferencesProvider);
      expect(prefs.themeMode, AppThemeMode.system);
    });

    test('setThemeMode updates state and persists', () async {
      await container.read(userPreferencesProvider.notifier).setThemeMode(AppThemeMode.dark);
      
      final prefs = container.read(userPreferencesProvider);
      expect(prefs.themeMode, AppThemeMode.dark);

      final sharedPrefs = await SharedPreferences.getInstance();
      expect(sharedPrefs.getInt('theme_mode'), AppThemeMode.dark.index);
    });
  });
}
