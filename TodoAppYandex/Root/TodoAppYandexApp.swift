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
        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
    }
}
