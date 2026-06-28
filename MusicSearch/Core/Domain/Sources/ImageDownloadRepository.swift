import Foundation

public protocol ImageDownloadRepository: Sendable {
    func downloadImage(from url: URL) async throws -> Data
}
