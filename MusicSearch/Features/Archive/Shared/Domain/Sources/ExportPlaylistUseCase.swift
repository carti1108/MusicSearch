//
//  ExportPlaylistUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol ExportPlaylistUseCase: Sendable {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress>
}
