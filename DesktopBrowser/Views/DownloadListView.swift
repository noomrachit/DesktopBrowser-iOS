import SwiftUI
import UIKit

struct DownloadListView: View {
    @EnvironmentObject private var manager: DownloadManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if manager.records.isEmpty {
                    ContentUnavailableView("ยังไม่มีไฟล์", systemImage: "arrow.down.circle")
                } else {
                    ForEach(manager.records) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(record.fileName).lineLimit(2)
                            HStack {
                                Label(status(record), systemImage: icon(record))
                                    .font(.caption)
                                    .foregroundStyle(color(record))
                                Spacer()
                                if record.state == .completed, let url = record.destination {
                                    ShareLink(item: url) {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                }
                            }
                            if let message = record.errorMessage {
                                Text(message).font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("ดาวน์โหลด")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("ปิด") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ล้าง") { manager.clearFinished() }
                        .disabled(!manager.records.contains { $0.state != .downloading })
                }
            }
        }
    }

    private func status(_ record: DownloadRecord) -> String {
        switch record.state {
        case .downloading: "กำลังดาวน์โหลด"
        case .completed: "เสร็จแล้ว"
        case .failed: "ไม่สำเร็จ"
        }
    }

    private func icon(_ record: DownloadRecord) -> String {
        switch record.state {
        case .downloading: "arrow.down.circle"
        case .completed: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private func color(_ record: DownloadRecord) -> Color {
        switch record.state {
        case .downloading: .blue
        case .completed: .green
        case .failed: .red
        }
    }
}
