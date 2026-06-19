//
//  FlutterEngineManager.swift
//  TestMiniAppFlutter
//
//  Created by Nghiem Dinh Bach on 13/5/26.
//

import Flutter
import FlutterPluginRegistrant

final class FlutterEngineManager {

    static let shared = FlutterEngineManager()

    private var miniAppEngine: FlutterEngine?
    private var splashEngine: FlutterEngine?

    private init() {}

    // MARK: - Mini App

    func startMiniAppEngine() -> FlutterEngine {
        if let engine = miniAppEngine {
            return engine
        }

        let engine = FlutterEngine(name: "mini_app_engine_main")

        engine.run(withEntrypoint: "miniAppMain")

        GeneratedPluginRegistrant.register(with: engine)

        miniAppEngine = engine

        return engine
    }

    func startSplashEngine() -> FlutterEngine {
        if let engine = splashEngine {
            return engine
        }

        let engine = FlutterEngine(name: "mini_app_engine_splash")

        engine.run(withEntrypoint: "miniAppSplash")

        GeneratedPluginRegistrant.register(with: engine)

        splashEngine = engine

        return engine
    }
}
