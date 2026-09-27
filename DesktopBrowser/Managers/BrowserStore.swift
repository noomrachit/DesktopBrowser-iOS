import Foundation

@MainActor
final class BrowserStore: ObservableObject {
    @Published private(set) var tabs: [BrowserTab] = []
    @Published var selectedID: UUID?

    var selectedTab: BrowserTab? {
        tabs.first { $0.id == selectedID }
    }

    func start(downloadManager: DownloadManager) {
        guard tabs.isEmpty else { return }
        addTab(downloadManager: downloadManager)
    }

    func addTab(downloadManager: DownloadManager, startURL: URL? = URL(string: "https://www.google.com")) {
        let tab = BrowserTab(downloadManager: downloadManager, startURL: startURL)
        tabs.append(tab)
        selectedID = tab.id
    }

    func select(_ tab: BrowserTab) {
        selectedID = tab.id
    }

    func close(_ tab: BrowserTab, downloadManager: DownloadManager) {
        guard let index = tabs.firstIndex(where: { $0.id == tab.id }) else { return }
        let wasSelected = selectedID == tab.id
        tabs.remove(at: index)

        if tabs.isEmpty {
            addTab(downloadManager: downloadManager)
        } else if wasSelected {
            selectedID = tabs[min(index, tabs.count - 1)].id
        }
    }
}
