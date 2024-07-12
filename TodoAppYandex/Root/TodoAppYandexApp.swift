//
//  TodoAppYandexApp.swift
//  TodoAppYandex
//
//  Created by Григорий Громов on 22.06.2024.
//

import SwiftUI
import CocoaLumberjack

@main
struct TodoAppYandexApp: App {

    init() {
        self.setupLogging()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()

        }
    }

    private func setupLogging() {
        // Установка логгера для консоли
        DDLog.add(DDOSLogger.sharedInstance)

        // Можно добавить дополнительные логгеры, например, для файлового логирования
        let fileLogger: DDFileLogger = DDFileLogger() // Инициализация файлового логгера
        fileLogger.rollingFrequency = TimeInterval(60*60*24) // Log file rolling frequency (24 hours)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7 // Keep max 7 log files
        DDLog.add(fileLogger)
    }
}
