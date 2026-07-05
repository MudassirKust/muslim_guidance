import Flutter
import UIKit
import FBAudienceNetwork
import AppTrackingTransparency
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {

  // ADD THIS — keep a strong reference so it isn't deallocated
  var nativeAdFactory: NativeAdFactory?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // ADD THIS BLOCK — register native ad factory (must be after GeneratedPluginRegistrant.register)
    let factory = NativeAdFactory()
    self.nativeAdFactory = factory
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
      self,
      factoryId: "medium_280",
      nativeAdFactory: factory
    )

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Meta Audience Network consent — called before MobileAds.initialize() on the Dart side
    if let controller = window?.rootViewController as? FlutterViewController {
      let metaChannel = FlutterMethodChannel(
        name: "com.muslimguidance/meta_consent",
        binaryMessenger: controller.binaryMessenger
      )
      metaChannel.setMethodCallHandler { call, result in
        if call.method == "initializeMetaAAN" {
          FBAdSettings.setDataProcessingOptions([])
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Request App Tracking Transparency permission (iOS 14+) before ads initialise
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization { _ in }
      }
    }

    return result
  }

  override func applicationWillResignActive(_ application: UIApplication) {
    // Prevent cleanup when app goes to background
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Keep background audio running
  }

  // ADD THIS — unregister to avoid memory leaks
  override func applicationWillTerminate(_ application: UIApplication) {
    FLTGoogleMobileAdsPlugin.unregisterNativeAdFactory(self, factoryId: "medium_280")
  }
}
