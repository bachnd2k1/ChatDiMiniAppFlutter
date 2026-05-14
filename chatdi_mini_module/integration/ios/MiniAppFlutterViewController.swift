import Flutter
import UIKit

/// Subclass mẫu khi host dùng **một** `FlutterEngine` dùng chung (singleton manager).
///
/// ## Lỗi đỏ `_elements.contains(element)': is not true`
/// Thường do gỡ surface quá sớm: gán `engine.viewController = nil` **đồng bộ** ngay trong
/// `viewDidDisappear`, hoặc dùng `parent == nil` (timing lệch với interactive pop / transition).
/// Cách an toàn: chỉ gỡ khi thật sự **pop** hoặc **dismiss**, và **defer** sang vòng lặp runloop sau.
///
/// ## `makeViewController()` chỉ được tạo & return VC
/// Không được gọi `dismiss` / `popViewController` trên VC vừa `init` — đó là lỗi logic;
/// đóng màn hãy để Flutter gọi `MethodChannel('chatdi/mini_app').invokeMethod('close')`
/// (xử lý dismiss/pop trong **handler** channel, giống `ChatDiFlutterMiniAppFactory`).
///
/// ## Shared engine + MethodChannel
/// Đăng ký `FlutterMethodChannel(...).setMethodCallHandler` **một lần** khi tạo engine,
/// không đăng ký lại mỗi lần `makeViewController()` nếu không muốn ghi đè handler.
open class MiniAppFlutterViewController: FlutterViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Chỉ gỡ khi đang rời stack / đang bị dismiss — tránh nhầm khi chỉ bị che bởi màn push lên.
        guard isMovingFromParent || isBeingDismissed else { return }

        let attachedEngine = engine
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if attachedEngine.viewController === self {
                attachedEngine.viewController = nil
            }
        }
    }
}
