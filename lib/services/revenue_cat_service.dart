import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  static const String entitlementId = 'Muslim Guidance Pro';

  static const String _apiKeyIos = 'test_RVWKspfyzeqZBLvSvQPfDLcMPZW';
  static const String _apiKeyAndroid = 'goog_dzWzgvywcVNQUaXLsQArHBAqziW';

  Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.error,
      );

      final PurchasesConfiguration config;
      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        config = PurchasesConfiguration(_apiKeyIos);
      } else {
        config = PurchasesConfiguration(_apiKeyAndroid);
      }

      await Purchases.configure(config);
    } catch (e) {
      debugPrint('RevenueCatService.initialize error: $e');
    }
  }

  Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCatService.identifyUser error: $e');
    }
  }

  Future<void> resetUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCatService.resetUser error: $e');
    }
  }

  Future<CustomerInfo> getCustomerInfo() {
    return Purchases.getCustomerInfo();
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('RevenueCatService.getOfferings error: $e');
      return null;
    }
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }

  bool isEntitlementActive(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(entitlementId);
  }
}
