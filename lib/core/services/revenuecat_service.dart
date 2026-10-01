import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // Singleton pattern
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  List<Package> _packages = [];

  List<String> _prices = [];
  bool _isPro = false;

  bool get isPro => _isPro;
  List<Package> get packages => _packages;
  List<String> get prices => _prices;

  Future<void> init(String apiKey) async {
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isPro = await checkUserIsSubscription();
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }

  Future<bool> fetchPackages({
    List<String> fallbackPrices = const ["4.99\$", "13.99\$", "29.99\$"],
  }) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        _packages = offerings.current!.availablePackages;
        _prices = _packages.map((pkg) => pkg.storeProduct.priceString).toList();
        return true;
      } else {
        _packages = [];
        _prices = fallbackPrices;
        return false;
      }
    } catch (e) {
      print('error: $e');
      _packages = [];
      _prices = fallbackPrices;
      return false;
    }
  }

  Future<bool> checkUserIsSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Future<PaywallInfo> shouldShowPaywall() async {
  //   try {
  //     final customerInfo = await Purchases.getCustomerInfo();
  //     if (customerInfo.entitlements.active.isNotEmpty) {
  //       _isPro = true;
  //       return PaywallInfo(shouldShowPaywall: false, isSubscribed: true);
  //     }
  //     _isPro = false;
  //     return PaywallInfo(shouldShowPaywall: true, isSubscribed: false);
  //   } catch (e) {
  //     return PaywallInfo(
  //       shouldShowPaywall: false,
  //       isSubscribed: false,
  //       error: e.toString(),
  //     );
  //   }
  // }

  Future<PurchaseResult> purchase(int packageIndex) async {
    try {
      if (_packages.isEmpty) {
        return PurchaseResult(
          success: false,
          isSubscribed: false,
          error: 'No packages available. Call fetchPackages() first.',
        );
      }

      if (packageIndex < 0 || packageIndex >= _packages.length) {
        return PurchaseResult(
          success: false,
          isSubscribed: false,
          error: 'Invalid package index',
        );
      }

      final purchaseResult = await Purchases.purchasePackage(
        _packages[packageIndex],
      );
      final customerInfo = purchaseResult.customerInfo;
      final isSubscribed = customerInfo.entitlements.active.isNotEmpty;
      _isPro = isSubscribed;
      // Purchase has been successful
      return PurchaseResult(success: true, isSubscribed: isSubscribed);
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('cancelled') || errorString.contains('cancel')) {
        return PurchaseResult(
          success: false,
          isSubscribed: false,
          error: 'Purchase was cancelled',
          wasCancelled: true,
        );
      } else if (errorString.contains('already') &&
          errorString.contains('purchased')) {
        return PurchaseResult(
          success: false,
          isSubscribed: true,
          error: 'Product already purchased',
        );
      } else {
        return PurchaseResult(
          success: false,
          isSubscribed: false,
          error: 'Purchase failed: $e',
        );
      }
    }
  }

  Future<RestoreResult> restore() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasActiveSubscriptions =
          customerInfo.activeSubscriptions.isNotEmpty;
      _isPro = hasActiveSubscriptions;
      return RestoreResult(
        success: true,
        hasActiveSubscriptions: hasActiveSubscriptions,
        activeSubscriptions: customerInfo.activeSubscriptions,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        hasActiveSubscriptions: false,
        activeSubscriptions: [],
        error: 'Failed to restore purchases: $e',
      );
    }
  }
}

// ========== Data Classes ==========

/// Paywall information
class PaywallInfo {
  final bool shouldShowPaywall;
  final bool isSubscribed;
  final String? error;

  PaywallInfo({
    required this.shouldShowPaywall,
    required this.isSubscribed,
    this.error,
  });
}

/// Purchase result
class PurchaseResult {
  final bool success;
  final bool isSubscribed;
  final String? error;
  final bool wasCancelled;

  PurchaseResult({
    required this.success,
    required this.isSubscribed,
    this.error,
    this.wasCancelled = false,
  });
}

/// Restore purchases result
class RestoreResult {
  final bool success;
  final bool hasActiveSubscriptions;
  final List<String> activeSubscriptions;
  final String? error;

  RestoreResult({
    required this.success,
    required this.hasActiveSubscriptions,
    required this.activeSubscriptions,
    this.error,
  });
}
