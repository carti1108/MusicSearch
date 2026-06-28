import Foundation
import MSDomain

public struct ImageDownloadRepositoryImpl: ImageDownloadRepository {
    public init() {}
    
    public func downloadImage(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
