import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenue_cat_service.dart';

class SubscriptionController extends GetxController {
  final Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);
  final RxBool isLoading = false.obs;

  bool get isPremium {
    final info = customerInfo.value;
    if (info == null) return false;
    return RevenueCatService.instance.isEntitlementActive(info);
  }

  @override
  void onInit() {
    super.onInit();
    refreshCustomerInfo();
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }

  @override
  void onClose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.onClose();
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    customerInfo.value = info;
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      isLoading.value = true;
      final info = await RevenueCatService.instance.purchasePackage(package);
      customerInfo.value = info;
      // Return true when the purchase completes — don't gate on isPremium here
      // because the entitlement may not be reflected immediately, which would
      // silently skip the Firestore write even though payment succeeded.
      return true;
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      isLoading.value = true;
      final info = await RevenueCatService.instance.restorePurchases();
      customerInfo.value = info;
      return isPremium;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Offerings?> getOfferings() =>
      RevenueCatService.instance.getOfferings();

  Future<void> refreshCustomerInfo() async {
    try {
      final info = await RevenueCatService.instance.getCustomerInfo();
      customerInfo.value = info;
    } catch (_) {
      // Non-fatal — stays in free state until next refresh.
    }
  }
}
