import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:islamlearning/models/user_subscription.dart';
import 'package:islamlearning/views/nav_screen.dart';
import 'package:islamlearning/views/premium_screen.dart';
import '../services/revenue_cat_service.dart';
import 'subscription_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final Rx<UserSubscription?> subscription = Rx<UserSubscription?>(null);

  bool get isSignedIn => currentUser.value != null;

  /// User is premium if they have an active RevenueCat entitlement
  /// OR a valid Firestore subscription record.
  bool get isPremium {
    final rcPremium = Get.find<SubscriptionController>().isPremium;
    final fbPremium = subscription.value?.isActive == true;
    return rcPremium || fbPremium;
  }

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
    // Use a named method — avoids async closures directly in ever(), which
    // silently swallow exceptions in GetX.
    ever(currentUser, _onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    if (user != null) {
      // Fire-and-forget; failures are non-fatal and logged inside each method.
      _loadSubscription(user.uid);
      _identifyInRevenueCat(user.uid);
    } else {
      subscription.value = null;
    }
  }

  Future<void> _identifyInRevenueCat(String uid) async {
    await RevenueCatService.instance.identifyUser(uid);
    await Get.find<SubscriptionController>().refreshCustomerInfo();
    await _syncSubscriptionIfNeeded();
  }

  Future<void> _loadSubscription(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        subscription.value = UserSubscription.fromFirestore(doc);
      }
    } catch (e) {
      // Subscription load failure is non-fatal.
    }
  }

  /// If RevenueCat shows an active subscription but Firestore has no record,
  /// backfill the Firestore document. Handles users who purchased before the
  /// Firestore write was fixed.
  Future<void> _syncSubscriptionIfNeeded() async {
    final subController = Get.find<SubscriptionController>();
    if (!subController.isPremium) return; // RC says no premium — nothing to sync
    if (subscription.value != null) return; // Firestore already has a record — skip

    // Derive plan from RC active subscriptions
    final activeSubs = subController.customerInfo.value?.activeSubscriptions ?? [];
    final plan = activeSubs.any((id) => id.toLowerCase().contains('yearly'))
        ? 'yearly'
        : 'monthly';

    await saveSubscription(plan);
  }

  /// Saves a Firestore record after a successful RevenueCat purchase.
  /// [plan] must be 'monthly' or 'yearly'.
  Future<void> saveSubscription(String plan) async {
    final user = currentUser.value;
    if (user == null) return;

    final now = DateTime.now();
    final expiresAt = plan == 'yearly'
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);

    final newSub = UserSubscription(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      plan: plan,
      subscribedAt: now,
      expiresAt: expiresAt,
      isActive: true,
    );

    await _firestore.collection('users').doc(user.uid).set(newSub.toFirestore());
    subscription.value = newSub;
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final uid = userCredential.user!.uid;

      // Await both so isPremium is accurate before navigating.
      // The ever() observer also fires here but these are idempotent.
      await Future.wait([
        _loadSubscription(uid),
        _identifyInRevenueCat(uid),
      ]);

      if (isPremium) {
        Get.off(() => NavScreen());
      } else {
        Get.off(() => const PremiumScreen());
      }
    } catch (e) {
      Get.snackbar(
        'Sign In Failed',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    subscription.value = null;
    await RevenueCatService.instance.resetUser();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
