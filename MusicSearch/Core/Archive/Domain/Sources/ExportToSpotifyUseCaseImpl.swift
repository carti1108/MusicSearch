import Foundation

public final class ExportToSpotifyUseCaseImpl: ExportToSpotifyUseCase {
    private let spotifyRepository: SpotifyRepository
    
    public init(spotifyRepository: SpotifyRepository) {
        self.spotifyRepository = spotifyRepository
    }
    
    public func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        return AsyncStream { continuation in
            Task {
                var currentCount = 0
                var failedTracks: [ArchivedTrack] = []
                let totalCount = tracks.count
                

                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: "SpotifyAccessToken",
                    kSecReturnData as String: kCFBooleanTrue!,
                    kSecMatchLimit as String: kSecMatchLimitOne
                ]
                var dataTypeRef: AnyObject?
                var token: String? = nil
                if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr {
                    if let data = dataTypeRef as? Data {
                        token = String(data: data, encoding: .utf8)
                    }
                }
                
                guard let validToken = token else {
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: 0, failedTracks: tracks, isComplete: true))
                    continuation.finish()
                    return
                }
                
                do {
                    let userId = try await spotifyRepository.getUserProfile(token: validToken)
                    let playlistId = try await spotifyRepository.createPlaylist(userId: userId, name: playlistName, token: validToken)
                    
                    var urisToAdd: [String] = []
                    
                    for track in tracks {
                        do {
                            if let spotifyURI = track.platformIDs["spotify"] {
                                let uriToUse = spotifyURI.hasPrefix("spotify:track:") ? spotifyURI : "spotify:track:\(spotifyURI)"
                                urisToAdd.append(uriToUse)
                            } else if let uri = try await spotifyRepository.searchTrack(title: track.title, artist: track.artist, token: validToken) {
                                urisToAdd.append(uri)
                            } else {
                                failedTracks.append(track)
                            }
                        } catch {
                            failedTracks.append(track)
                        }
                        
                        currentCount += 1
                        continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: false))
                        
                        if urisToAdd.count >= 100 {
                            try await spotifyRepository.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                            urisToAdd.removeAll()
                        }
                    }
                    
                    if !urisToAdd.isEmpty {
                        try await spotifyRepository.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                    }
                    
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: true))
                    continuation.finish()
                    
                } catch {
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: tracks, isComplete: true))
                    continuation.finish()
                }
            }
        }
    }
}
