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
                                switch record.state {
                                case .downloading:
                                    Button { manager.pause(record.id) } label: {
                                        Image(systemName: "pause.circle")
                                    }
                                case .paused:
                                    Button { manager.resume(record.id) } label: {
                                        Image(systemName: "play.circle")
                                    }
                                case .completed:
                                    if let url = record.destination {
                                        ShareLink(item: url) {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                    }
                                case .failed:
                                    EmptyView()
                                }
                            }
                            if record.state == .downloading || record.state == .paused {
                                if let fractionCompleted = record.fractionCompleted {
                                    ProgressView(value: fractionCompleted)
                                        .progressViewStyle(.linear)
                                        .tint(color(record))
                                } else {
                                    ProgressView()
                                        .progressViewStyle(.linear)
                                        .tint(color(record))
                                }
                                if let formattedProgress = record.formattedProgress {
                                    Text(formattedProgress).font(.caption2).foregroundStyle(.secondary)
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
        case .paused: "หยุดชั่วคราว"
        case .completed: "เสร็จแล้ว"
        case .failed: "ไม่สำเร็จ"
        }
    }

    private func icon(_ record: DownloadRecord) -> String {
        switch record.state {
        case .downloading: "arrow.down.circle"
        case .paused: "pause.circle.fill"
        case .completed: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        }
    }

    private func color(_ record: DownloadRecord) -> Color {
        switch record.state {
        case .downloading: .blue
        case .paused: .orange
        case .completed: .green
        case .failed: .red
        }
    }
}
