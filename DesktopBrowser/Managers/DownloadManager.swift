import Foundation
import WebKit

@MainActor
final class DownloadManager: NSObject, ObservableObject, WKDownloadDelegate {
    @Published private(set) var records: [DownloadRecord] = []
    private var recordIDs: [ObjectIdentifier: UUID] = [:]
    private var activeDownloads: [UUID: WKDownload] = [:]
    private var originWebViews: [UUID: WKWebView] = [:]
    private var progressObservations: [UUID: NSKeyValueObservation] = [:]
    private var pausedResumeData: [UUID: Data] = [:]

    func attach(_ download: WKDownload) {
        let id = UUID()
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
        register(download, id: id)
    }

    func pause(_ id: UUID) {
        guard let download = activeDownloads[id] else { return }
        let key = ObjectIdentifier(download)
        download.cancel { [weak self] resumeData in
            Task { @MainActor in
                guard let self else { return }
                self.recordIDs.removeValue(forKey: key)
                self.activeDownloads.removeValue(forKey: id)
                self.progressObservations.removeValue(forKey: id)
                guard let index = self.records.firstIndex(where: { $0.id == id }) else { return }
                if let resumeData {
                    self.pausedResumeData[id] = resumeData
                    self.records[index].state = .paused
                } else {
                    self.records[index].state = .failed
                    self.records[index].errorMessage = "ไม่สามารถหยุดชั่วคราวได้"
                    self.originWebViews.removeValue(forKey: id)
                }
            }
        }
    }

    func resume(_ id: UUID) {
        guard let resumeData = pausedResumeData[id],
              let webView = originWebViews[id] else { return }
        webView.resumeDownload(fromResumeData: resumeData) { [weak self] download in
            Task { @MainActor in
                guard let self else { return }
                self.pausedResumeData.removeValue(forKey: id)
                self.register(download, id: id)
                guard let index = self.records.firstIndex(where: { $0.id == id }) else { return }
                self.records[index].state = .downloading
                self.records[index].errorMessage = nil
            }
        }
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
            self.records[index].fileName = destination.lastPathComponent
            self.records[index].destination = destination
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
        let removableIDs = records.filter { $0.state != .downloading }.map(\.id)
        records.removeAll { $0.state != .downloading }
        for id in removableIDs {
            activeDownloads.removeValue(forKey: id)
            originWebViews.removeValue(forKey: id)
            progressObservations.removeValue(forKey: id)
            pausedResumeData.removeValue(forKey: id)
        }
    }

    private func register(_ download: WKDownload, id: UUID) {
        download.delegate = self
        recordIDs[ObjectIdentifier(download)] = id
        activeDownloads[id] = download
        if let webView = download.webView {
            originWebViews[id] = webView
        }
        progressObservations[id] = download.progress.observe(\.completedUnitCount, options: [.new]) { [weak self] progress, _ in
            Task { @MainActor in self?.updateBytes(id: id, progress: progress) }
        }
    }

    private func updateBytes(id: UUID, progress: Progress) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].totalBytesWritten = progress.completedUnitCount
        records[index].totalBytesExpectedToWrite = progress.totalUnitCount
    }

    private func finish(_ download: WKDownload, error: Error?) {
        let key = ObjectIdentifier(download)
        guard let id = recordIDs[key],
              let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].state = error == nil ? .completed : .failed
        records[index].errorMessage = error?.localizedDescription
        recordIDs.removeValue(forKey: key)
        activeDownloads.removeValue(forKey: id)
        originWebViews.removeValue(forKey: id)
        progressObservations.removeValue(forKey: id)
        pausedResumeData.removeValue(forKey: id)
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
