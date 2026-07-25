//
//  MockArchiveRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ArchiveDomain

public final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    public var tracks: [ArchivedTrack]
    public init(tracks: [ArchivedTrack]) { self.tracks = tracks }

    public func fetchArchivedTracks() async throws -> [ArchivedTrack] { return tracks }
    public func fetchFolderContents(for folderItem: FolderItem) async throws -> FolderContents {
        return FolderContents(folders: nil, tracks: tracks)
    }
    public func addArchivedTrack(_ track: ArchivedTrack) async throws {
        tracks.append(track)
    }
    public func updateArchivedTrack(_ track: ArchivedTrack) async throws {
        if let index = tracks.firstIndex(where: { $0.id == track.id }) {
            tracks[index] = track
        }
    }
    public func deleteArchivedTrack(id: UUID) async throws {
        tracks.removeAll(where: { $0.id == id })
    }
}
