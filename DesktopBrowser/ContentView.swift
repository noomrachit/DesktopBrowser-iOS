import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: BrowserStore
    @EnvironmentObject private var downloads: DownloadManager
    @State private var showDownloads = false

    var body: some View {
        VStack(spacing: 0) {
            TabStripView()

            if let tab = store.selectedTab {
                NavigationBarView(tab: tab, showDownloads: $showDownloads)
                    .id(tab.id)

                BrowserWebView(webView: tab.webView)
                    .id(tab.id)
                    .ignoresSafeArea(.container, edges: .bottom)
            } else {
                ProgressView()
            }
        }
        .onAppear { store.start(downloadManager: downloads) }
        .sheet(isPresented: $showDownloads) {
            DownloadListView().environmentObject(downloads)
        }
    }
}

/// ติดตามแท็บโดยตรงด้วย @ObservedObject เพื่อให้ปุ่ม แถบโหลด และช่อง URL อัปเดตตามสถานะแท็บ
private struct NavigationBarView: View {
    @ObservedObject var tab: BrowserTab
    @Binding var showDownloads: Bool
    @EnvironmentObject private var downloads: DownloadManager
    @State private var addressText = ""
    @FocusState private var addressFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button { tab.goBack() } label: { Image(systemName: "chevron.left") }
                    .disabled(!tab.canGoBack)
                Button { tab.goForward() } label: { Image(systemName: "chevron.right") }
                    .disabled(!tab.canGoForward)
                Button { tab.isLoading ? tab.stop() : tab.reload() } label: {
                    Image(systemName: tab.isLoading ? "xmark" : "arrow.clockwise")
                }

                TextField("ค้นหาหรือพิมพ์ URL", text: $addressText)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .submitLabel(.go)
                    .focused($addressFocused)
                    .onSubmit {
                        tab.navigate(addressText)
                        addressFocused = false
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 38)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Capsule())

                Button { showDownloads = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "arrow.down.circle")
                        if downloads.records.contains(where: { $0.state == .downloading }) {
                            Circle().fill(.blue).frame(width: 7, height: 7)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 10)
            .frame(height: 52)
            .background(.regularMaterial)

            if tab.isLoading {
                ProgressView(value: tab.progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
            }
        }
        .onAppear { addressText = tab.urlText }
        .onChange(of: tab.urlText) { _, newValue in
            if !addressFocused { addressText = newValue }
        }
        .onChange(of: addressFocused) { _, focused in
            if !focused { addressText = tab.urlText }
        }
    }
}
