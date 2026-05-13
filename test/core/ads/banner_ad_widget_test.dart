import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pactora/core/ads/banner_ad_widget.dart';
import 'package:pactora/core/providers/user_preferences_provider.dart';

void main() {
  testWidgets('BannerAdWidget returns SizedBox.shrink() when isPremium is true', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isPremiumProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: BannerAdWidget(),
          ),
        ),
      ),
    );

    expect(find.byType(BannerAdWidget), findsOneWidget);
    expect(find.byType(AdWidget), findsNothing);
    
    // Check if it's effectively empty (SizedBox.shrink)
    final SizedBox sizedBox = tester.widget(find.descendant(
      of: find.byType(BannerAdWidget),
      matching: find.byType(SizedBox),
    ));
    expect(sizedBox.width, 0);
    expect(sizedBox.height, 0);
  });
}
