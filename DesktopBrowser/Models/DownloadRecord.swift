import Foundation

enum DownloadState: String, Codable {
    case downloading
    case completed
    case failed
}

struct DownloadRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let fileName: String
    var destination: URL?
    var state: DownloadState
    var errorMessage: String?
    let startedAt: Date
}
