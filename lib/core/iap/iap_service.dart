import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pactora/core/providers/user_preferences_provider.dart';

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

class IapService {
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String premium7DaysId = 'premium_7_days';
  static const String premium30DaysId = 'premium_30_days';
  static const String premiumLifetimeId = 'premium_lifetime';
  
  // For testing on Android, you can use 'android.test.purchased'
  static const String testPremiumId = 'android.test.purchased';

  final _productsController = StreamController<List<ProductDetails>>.broadcast();
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  IapService(this._ref);

  void init() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onError: (error) {
        debugPrint('IAP Critical Error: $error');
        _errorController.add('IAP service error: $error');
      },
    );
  }

  void dispose() {
    _subscription?.cancel();
    _productsController.close();
    _errorController.close();
    _purchaseController.close();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Purchase Pending: ${purchaseDetails.productID}');
      } else {
        _purchaseController.add(purchaseDetails);
        if (purchaseDetails.status == PurchaseStatus.error) {
          final errorMessage = purchaseDetails.error?.message ?? 'Unknown error';
          debugPrint('Purchase Error [${purchaseDetails.productID}]: $errorMessage');
          _errorController.add('Purchase failed: $errorMessage');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint('Purchase Successful/Restored: ${purchaseDetails.productID}');
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          } else {
            debugPrint('Purchase Validation Failed: ${purchaseDetails.productID}');
            _errorController.add('Failed to verify purchase.');
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          debugPrint('Purchase Canceled: ${purchaseDetails.productID}');
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
    final notifier = _ref.read(userPreferencesProvider.notifier);
    
    if (purchaseDetails.productID == premiumLifetimeId || purchaseDetails.productID == testPremiumId) {
      await notifier.setLifetimePremium(true);
    } else if (purchaseDetails.productID == premium7DaysId) {
      await notifier.setPremiumExpiry(DateTime.now().add(const Duration(days: 7)));
    } else if (purchaseDetails.productID == premium30DaysId) {
      await notifier.setPremiumExpiry(DateTime.now().add(const Duration(days: 30)));
    }
  }

  Future<List<ProductDetails>> loadProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return [];
    }

    const Set<String> ids = {premium7DaysId, premium30DaysId, premiumLifetimeId, testPremiumId};
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
