import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pactora/core/services/guide_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GuideService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('shouldShowGuide returns true by default', () async {
      final result = await GuideService.shouldShowGuide();
      expect(result, isTrue);
    });

    test('markGuideShown sets flag to true', () async {
      await GuideService.markGuideShown();
      final result = await GuideService.shouldShowGuide();
      expect(result, isFalse);
    });

    test('shouldShowGuide returns false if already shown', () async {
      SharedPreferences.setMockInitialValues({'guide_shown': true});
      final result = await GuideService.shouldShowGuide();
      expect(result, isFalse);
    });
  });
}
