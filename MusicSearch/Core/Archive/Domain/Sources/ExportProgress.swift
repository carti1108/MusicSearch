import Foundation

public struct ExportProgress: Sendable {
    public let totalCount: Int
    public let currentCount: Int
    public let failedTracks: [ArchivedTrack]
    public let isComplete: Bool
    
    public init(totalCount: Int, currentCount: Int, failedTracks: [ArchivedTrack], isComplete: Bool = false) {
        self.totalCount = totalCount
        self.currentCount = currentCount
        self.failedTracks = failedTracks
        self.isComplete = isComplete
    }
}
