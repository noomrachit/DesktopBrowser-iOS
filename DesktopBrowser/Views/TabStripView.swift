import SwiftUI

struct TabStripView: View {
    @EnvironmentObject private var store: BrowserStore
    @EnvironmentObject private var downloads: DownloadManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(store.tabs) { tab in
                    TabChip(
                        tab: tab,
                        isSelected: store.selectedID == tab.id,
                        onSelect: { store.select(tab) },
                        onClose: { store.close(tab, downloadManager: downloads) }
                    )
                }

                Button {
                    store.addTab(downloadManager: downloads)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 42)
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

/// ติดตามแท็บโดยตรงเพื่อให้ชื่อแท็บอัปเดตเมื่อหน้าเว็บเปลี่ยน
private struct TabChip: View {
    @ObservedObject var tab: BrowserTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 5) {
            Button(action: onSelect) {
                Text(tab.title)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(maxWidth: 130, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 34)
        .background(isSelected ? Color(uiColor: .systemBackground) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 9))
    }
}
