import Flutter
import UIKit
import CoreMotion

public class GyroscopePlugin: NSObject, FlutterPlugin {
  private let motionManager = CMMotionManager()
  private let channel: FlutterMethodChannel

  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gyroscope", binaryMessenger: registrar.messenger())
    let instance = GyroscopePlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "subscribe":
      if let us = call.arguments as? Double {
        subscribe(us)
        result(true)
      } else {
        result(false)
      }

    case "unsubscribe":
      unsubscribe()
      result(nil)

    default:
      result(nil)
    }
  }

  private func subscribe(_ us: Double) {
    if motionManager.isGyroAvailable {
      motionManager.gyroUpdateInterval = us

      motionManager.startGyroUpdates(to: .main) { gyroData, error in
        if let gyroData = gyroData {
          let rotationRate = gyroData.rotationRate

          self.channel.invokeMethod("data", arguments: ["azimuth": rotationRate.x, "pitch": rotationRate.y, "roll": rotationRate.z])
        } else if let error = error {
          print("Error accessing gyroscope data: \(error.localizedDescription)")
        }
      }
    } else {
      print("Gyroscope is not available on this device.")
    }
  }

  private func unsubscribe() {
    motionManager.stopGyroUpdates()
  }
}
