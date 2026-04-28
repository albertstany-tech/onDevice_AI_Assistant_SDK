import Flutter
import UIKit

public class OnDeviceAiPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private let runner = CoreMLRunner()
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "on_device_ai", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "on_device_ai_stream", binaryMessenger: registrar.messenger())
    
    let instance = OnDeviceAiPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    
    switch call.method {
    case "loadModel":
      guard let modelName = args?["modelName"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "modelName is required", details: nil))
        return
      }
      let config = args?["config"] as? [String: Any]
      let useGPU = config?["useGPU"] as? Bool ?? true
      
      do {
        try runner.loadModel(name: modelName, useGPU: useGPU)
        result(nil)
      } catch {
        result(FlutterError(code: "LOAD_FAILED", message: "Failed to load model \(modelName)", details: error.localizedDescription))
      }
      
    case "runText":
      guard let prompt = args?["prompt"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "prompt is required", details: nil))
        return
      }
      
      do {
        let output = try runner.runText(prompt: prompt)
        result(output)
      } catch {
        result(FlutterError(code: "INFERENCE_FAILED", message: "Text inference failed", details: error.localizedDescription))
      }
      
    case "runImage":
      guard let imageBytes = args?["imageBytes"] as? FlutterStandardTypedData else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "imageBytes is required", details: nil))
        return
      }
      
      do {
        let output = try runner.runImage(imageBytes: imageBytes)
        result(output)
      } catch {
        result(FlutterError(code: "INFERENCE_FAILED", message: "Image inference failed", details: error.localizedDescription))
      }
      
    case "startStreamText":
      guard let _ = args?["prompt"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "prompt is required", details: nil))
        return
      }
      // Stream handler logic mock
      DispatchQueue.global().async {
          let words = ["This", "is", "a", "mocked", "stream", "response"]
          for word in words {
              Thread.sleep(forTimeInterval: 0.2)
              DispatchQueue.main.async {
                  self.eventSink?(word)
              }
          }
          DispatchQueue.main.async {
              self.eventSink?(FlutterEndOfEventStream)
          }
      }
      result(nil)
      
    case "dispose":
      runner.dispose()
      result(nil)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = events
      return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      self.eventSink = nil
      return nil
  }
}
