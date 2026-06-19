//
//  FlutterMiniAppFactory.swift
//  TestMiniAppFlutter
//
//  Created by Nghiem Dinh Bach on 13/5/26.
//

import UIKit
import Flutter

/// FlutterViewController gắn engine dùng chung; khi pop khỏi nav stack cần gỡ engine
/// khỏi VC cũ để lần push sau vẽ lại đúng (tránh màn đen / surface cũ).
final class MiniAppFlutterViewController: FlutterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

public final class FlutterMiniAppFactory {
    
    public init() {}
    
    public func makeMainViewController() -> FlutterViewController {
        let engine = FlutterEngineManager.shared.startMiniAppEngine()
        let flutterVC = MiniAppFlutterViewController(
            engine: engine,
            nibName: nil,
            bundle: nil
        )
        flutterVC.hidesBottomBarWhenPushed = true
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
    
    public func makeSplashViewController() -> FlutterViewController {
        let flutterVC = MiniAppFlutterViewController(
            engine: FlutterEngineManager.shared.startSplashEngine(),
            nibName: nil,
            bundle: nil
        )
        flutterVC.hidesBottomBarWhenPushed = true
        return flutterVC
    }
}
