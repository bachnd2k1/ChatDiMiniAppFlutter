import Flutter
import FlutterPluginRegistrant
import UIKit

/// Mở mini app ChatDI (Dart entrypoint `miniAppMain` trong lib/main.dart).
/// Giữ tham chiếu tới `FlutterEngine` trong suốt vòng đời màn Flutter.
///
/// **Host app:** `makeViewController()` chỉ tạo và trả về VC — không gọi `dismiss`/`pop` ở đây.
/// Logic đóng nằm trong handler `chatdi/mini_app` method `close`. Nếu dùng shared engine,
/// xem `MiniAppFlutterViewController.swift` (gỡ `viewController` an toàn, tránh assertion Flutter).
public final class ChatDiFlutterMiniAppFactory: NSObject {
    private var engine: FlutterEngine?

    public override init() {
        super.init()
    }

    /// Tạo `FlutterViewController` full-screen hoặc embed vào container view.
    public func makeViewController() -> FlutterViewController {
        let engine = FlutterEngine(name: "chatdi_mini_engine")
        engine.run(withEntrypoint: "miniAppMain")
        GeneratedPluginRegistrant.register(with: engine)
        self.engine = engine

        let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        let channel = FlutterMethodChannel(
            name: "chatdi/mini_app",
            binaryMessenger: engine.binaryMessenger
        )
        channel.setMethodCallHandler { [weak flutterVC] call, result in
            guard call.method == "close" else {
                result(FlutterMethodNotImplemented)
                return
            }
            DispatchQueue.main.async {
                guard let vc = flutterVC else {
                    result(nil)
                    return
                }
                if vc.presentingViewController != nil {
                    vc.dismiss(animated: true) { result(nil) }
                } else if let nav = vc.navigationController {
                    if nav.viewControllers.count > 1 {
                        nav.popViewController(animated: true)
                        result(nil)
                    } else if nav.presentingViewController != nil {
                        nav.dismiss(animated: true) { result(nil) }
                    } else {
                        result(
                            FlutterError(
                                code: "close_unhandled",
                                message: "Host app must pop or dismiss this Flutter screen.",
                                details: nil
                            )
                        )
                    }
                } else {
                    result(
                        FlutterError(
                            code: "close_unhandled",
                            message: "No presentingViewController or navigationController.",
                            details: nil
                        )
                    )
                }
            }
        }

        return flutterVC
    }

    /// Ví dụ đẩy từ `UIViewController` hiện tại.
    public func present(from host: UIViewController, animated: Bool = true) {
        let flutterVC = makeViewController()
        flutterVC.modalPresentationStyle = .fullScreen
        host.present(flutterVC, animated: animated)
    }
}
