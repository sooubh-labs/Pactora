import 'package:shared_preferences/shared_preferences.dart';

class GuideService {
  static const String _key = 'guide_shown';

  static Future<bool> shouldShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markGuideShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
