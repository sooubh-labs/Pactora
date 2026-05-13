import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();

  AdService._();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}
