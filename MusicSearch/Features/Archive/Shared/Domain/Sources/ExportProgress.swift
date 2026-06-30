import Foundation

public enum ExportError: Error, Sendable, Equatable {
    case unauthenticated
    case playlistCreationFailed
    case searchFailed
    case trackNotFound
    case unknown
}

public struct ExportFailure: Sendable, Equatable {
    public let track: ArchivedTrack?
    public let error: ExportError

    public init(track: ArchivedTrack?, error: ExportError) {
        self.track = track
        self.error = error
    }
}

public struct ExportProgress: Sendable, Equatable {
    public let totalCount: Int
    public let currentCount: Int
    public let failedTracks: [ExportFailure]
    public let isComplete: Bool
    public let fatalError: ExportError?

    public init(totalCount: Int, currentCount: Int, failedTracks: [ExportFailure], isComplete: Bool = false, fatalError: ExportError? = nil) {
        self.totalCount = totalCount
        self.currentCount = currentCount
        self.failedTracks = failedTracks
        self.isComplete = isComplete
        self.fatalError = fatalError
    }
}
