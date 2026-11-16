import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "devblock.tech.lotus_connect/foreground",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      if call.method == "setKeepScreenOn",
         let args = call.arguments as? [String: Any],
         let enable = args["enable"] as? Bool {
        DispatchQueue.main.async {
          UIApplication.shared.isIdleTimerDisabled = enable
        }
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
