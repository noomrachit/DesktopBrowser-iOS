import Foundation
import WebKit

@MainActor
final class DownloadManager: NSObject, ObservableObject, WKDownloadDelegate {
    @Published private(set) var records: [DownloadRecord] = []
    private var recordIDs: [ObjectIdentifier: UUID] = [:]

    func attach(_ download: WKDownload) {
        let id = UUID()
        recordIDs[ObjectIdentifier(download)] = id
        records.insert(
            DownloadRecord(
                id: id,
                fileName: "กำลังเตรียมไฟล์…",
                destination: nil,
                state: .downloading,
                errorMessage: nil,
                startedAt: Date()
            ),
            at: 0
        )
        download.delegate = self
    }

    nonisolated func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        let destination = Self.uniqueDestination(for: suggestedFilename)
        Task { @MainActor in
            guard let id = self.recordIDs[ObjectIdentifier(download)],
                  let index = self.records.firstIndex(where: { $0.id == id }) else {
                completionHandler(nil)
                return
            }
            self.records[index] = DownloadRecord(
                id: id,
                fileName: destination.lastPathComponent,
                destination: destination,
                state: .downloading,
                errorMessage: nil,
                startedAt: self.records[index].startedAt
            )
            completionHandler(destination)
        }
    }

    nonisolated func downloadDidFinish(_ download: WKDownload) {
        Task { @MainActor in self.finish(download, error: nil) }
    }

    nonisolated func download(
        _ download: WKDownload,
        didFailWithError error: Error,
        resumeData: Data?
    ) {
        Task { @MainActor in self.finish(download, error: error) }
    }

    func clearFinished() {
        records.removeAll { $0.state != .downloading }
    }

    private func finish(_ download: WKDownload, error: Error?) {
        let key = ObjectIdentifier(download)
        guard let id = recordIDs[key],
              let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].state = error == nil ? .completed : .failed
        records[index].errorMessage = error?.localizedDescription
        recordIDs.removeValue(forKey: key)
    }

    private nonisolated static func uniqueDestination(for suggestedFilename: String) -> URL {
        let manager = FileManager.default
        let documents = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folder = documents.appendingPathComponent("Downloads", isDirectory: true)
        try? manager.createDirectory(at: folder, withIntermediateDirectories: true)

        let sanitized = sanitize(suggestedFilename)
        let source = URL(fileURLWithPath: sanitized)
        let base = source.deletingPathExtension().lastPathComponent
        let ext = source.pathExtension
        var candidate = folder.appendingPathComponent(sanitized)
        var number = 1

        while manager.fileExists(atPath: candidate.path) {
            let suffix = ext.isEmpty ? "" : ".\(ext)"
            candidate = folder.appendingPathComponent("\(base) (\(number))\(suffix)")
            number += 1
        }
        return candidate
    }

    private nonisolated static func sanitize(_ value: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let pieces = value.components(separatedBy: forbidden)
        let result = pieces.joined(separator: "_").trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? "download" : String(result.prefix(180))
    }
}
