//
//  ArchiveRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation

public protocol ArchiveRepository: Sendable {
	func fetchArchivedTracks() async throws -> [ArchivedTrack]
	func fetchFolderContents(for folderItem: FolderItem) async throws -> FolderContents
	func addArchivedTrack(_ track: ArchivedTrack) async throws
	func updateArchivedTrack(_ track: ArchivedTrack) async throws
	func deleteArchivedTrack(id: UUID) async throws
	func fetchAllGenres() async throws -> [String]
}
