//
//  ExportPlaylistUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation
import OSLog
import MSDomain

public final class ExportPlaylistUseCaseImpl: ExportPlaylistUseCase {
    private let playlistExportService: PlaylistExportService
    private let authService: MusicAuthService

    public init(playlistExportService: PlaylistExportService, authService: MusicAuthService) {
        self.playlistExportService = playlistExportService
        self.authService = authService
    }

    public func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        let (stream, continuation) = AsyncStream.makeStream(of: ExportProgress.self)
        
        let task = Task {
            var currentCount = 0
            var failedTracks: [ExportFailure] = []
            let totalCount = tracks.count

            guard let validToken = authService.getAccessToken() else {
                continuation.yield(ExportProgress(totalCount: totalCount, currentCount: 0, failedTracks: [], isComplete: true, fatalError: .unauthenticated))
                continuation.finish()
                return
            }

            do {
                try Task.checkCancellation()
                let userId = try await playlistExportService.getUserProfile(token: validToken)
                let playlistId = try await playlistExportService.createPlaylist(userId: userId, name: playlistName, token: validToken)

                var urisToAdd: [String] = []

                for track in tracks {
                    try Task.checkCancellation()
                    do {
                        if let spotifyURI = track.platformIDs["spotify"] {
                            let uriToUse = spotifyURI.hasPrefix("spotify:track:") ? spotifyURI : "spotify:track:\(spotifyURI)"
                            urisToAdd.append(uriToUse)
                        } else if let uri = try await playlistExportService.searchTrack(title: track.title, artist: track.artist, token: validToken) {
                            urisToAdd.append(uri)
                        } else {
                            failedTracks.append(ExportFailure(track: track, error: .trackNotFound))
                        }
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ExportPlaylistUseCase")
                            .error("Failed to search track on Spotify: \(track.title) - \(error.localizedDescription)")
                        failedTracks.append(ExportFailure(track: track, error: .searchFailed))
                    }

                    currentCount += 1
                    continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: false))

                    if urisToAdd.count >= 100 {
                        try await playlistExportService.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                        urisToAdd.removeAll()
                    }
                }

                if !urisToAdd.isEmpty {
                    try Task.checkCancellation()
                    try await playlistExportService.addItemsToPlaylist(playlistId: playlistId, uris: urisToAdd, token: validToken)
                }

                continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: true))
                continuation.finish()

            } catch is CancellationError {
                continuation.finish()
            } catch {
                Logger(subsystem: "MusicSearch", category: "ExportPlaylistUseCase")
                    .error("Failed to create playlist or add tracks: \(error.localizedDescription)")
                continuation.yield(ExportProgress(totalCount: totalCount, currentCount: currentCount, failedTracks: failedTracks, isComplete: true, fatalError: .playlistCreationFailed))
                continuation.finish()
            }
        }

        continuation.onTermination = { @Sendable _ in
            task.cancel()
        }

        return stream
    }
}
