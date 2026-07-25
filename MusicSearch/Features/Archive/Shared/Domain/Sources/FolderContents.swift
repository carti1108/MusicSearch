//
//  FolderContents.swift
//  MusicSearch
//
//  Created by Kiseok on 7/25/26.
//

import Foundation

public struct FolderContents: Equatable, Sendable {
    public let folders: [FolderItem]?
    public let tracks: [ArchivedTrack]?

    public init(folders: [FolderItem]? = nil, tracks: [ArchivedTrack]? = nil) {
        self.folders = folders
        self.tracks = tracks
    }
}
