import SwiftUI

@main
struct DesktopBrowserApp: App {
    @StateObject private var browserStore = BrowserStore()
    @StateObject private var downloadManager = DownloadManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(browserStore)
                .environmentObject(downloadManager)
        }
    }
}
