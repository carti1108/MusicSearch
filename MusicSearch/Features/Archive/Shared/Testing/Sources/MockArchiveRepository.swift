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
    public func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    public func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    public func deleteArchivedTrack(id: UUID) async throws { }
}
