import Foundation
import MSDomain

public final class ExportToSpotifyUseCaseImpl: ExportToSpotifyUseCase {
    private let spotifyRepository: SpotifyRepository
    private let authRepository: SpotifyAuthRepository
    
    public init(spotifyRepository: SpotifyRepository, authRepository: SpotifyAuthRepository) {
        self.spotifyRepository = spotifyRepository
        self.authRepository = authRepository
    }
    
    public func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        return AsyncStream { continuation in
            let task = Task {
                var currentCount = 0
                var failedTracks: [ExportFailure] = []
                let totalCount = tracks.count
                
                guard let validToken = authRepository.getAccessToken() else {
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: 0, failedTracks: [], isComplete: true, fatalError: .unauthenticated))
                    continuation.finish()
                    return
                }
                
                do {
                    try Task.checkCancellation()
                    let userId = try await spotifyRepository.getUserProfile(token: validToken)
                    let playlistId = try await spotifyRepository.createPlaylist(userId: userId, name: playlistName, token: validToken)
                    
                    var urisToAdd: [String] = []
                    
                    for track in tracks {
                        try Task.checkCancellation()
                        do {
                            if let spotifyURI = track.platformIDs["spotify"] {
                                let uriToUse = spotifyURI.hasPrefix("spotify:track:") ? spotifyURI : "spotify:track:\(spotifyURI)"
                                urisToAdd.append(uriToUse)
                            } else if let uri = try await spotifyRepository.searchTrack(title: track.title, artist: track.artist, token: validToken) {
                                urisToAdd.append(uri)
                            } else {
                                failedTracks.append(ExportFailure(track: track, error: .trackNotFound))
                            }
                        } catch {
                            failedTracks.append(ExportFailure(track: track, error: .searchFailed))
                        }
                        
                        currentCount += 1
                        continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: false))
                        
                        if urisToAdd.count >= 100 {
                            try await spotifyRepository.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                            urisToAdd.removeAll()
                        }
                    }
                    
                    if !urisToAdd.isEmpty {
                        try Task.checkCancellation()
                        try await spotifyRepository.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                    }
                    
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: true))
                    continuation.finish()
                    
                } catch is CancellationError {
                    // Task was cancelled, exit cleanly
                    continuation.finish()
                } catch {
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: true, fatalError: .playlistCreationFailed))
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}
