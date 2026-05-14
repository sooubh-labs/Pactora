import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pactora/core/providers/user_preferences_provider.dart';

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(ref);
  service.init();
  return service;
});

class IapService {
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  static const String premiumId = 'pactora_premium_lifetime';
  // For testing on Android, you can use 'android.test.purchased'
  static const String testPremiumId = 'android.test.purchased';

  final _productsController = StreamController<List<ProductDetails>>.broadcast();
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;

  IapService(this._ref);

  void init() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        debugPrint('IAP Error: $error');
      },
    );
  }

  void dispose() {
    _subscription.cancel();
    _productsController.close();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase Error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // For a real app, verify with a backend or local validation
    // For this prototype, we'll assume it's valid if it reaches here
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == premiumId || purchaseDetails.productID == testPremiumId) {
      await _ref.read(userPreferencesProvider.notifier).updatePremiumStatus(true);
    }
  }

  Future<List<ProductDetails>> loadProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return [];
    }

    const Set<String> ids = {premiumId, testPremiumId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Products not found: ${response.notFoundIDs}');
    }

    _productsController.add(response.productDetails);
    return response.productDetails;
  }

  Future<void> buyPremium(ProductDetails productDetails) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
