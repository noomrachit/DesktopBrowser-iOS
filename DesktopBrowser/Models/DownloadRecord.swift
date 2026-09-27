import Foundation

enum DownloadState: String, Codable {
    case downloading
    case paused
    case completed
    case failed
}

struct DownloadRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var fileName: String
    var destination: URL?
    var state: DownloadState
    var errorMessage: String?
    let startedAt: Date
    var totalBytesWritten: Int64 = 0
    var totalBytesExpectedToWrite: Int64 = -1

    var fractionCompleted: Double? {
        guard totalBytesExpectedToWrite > 0 else { return nil }
        return Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
    }

    var formattedProgress: String? {
        guard let fractionCompleted, totalBytesExpectedToWrite > 0 else { return nil }
        let percent = Int((fractionCompleted * 100).rounded())
        let written = Self.byteFormatter.string(fromByteCount: totalBytesWritten)
        let total = Self.byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        return "\(percent)% • \(written) / \(total)"
    }

    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()
}
