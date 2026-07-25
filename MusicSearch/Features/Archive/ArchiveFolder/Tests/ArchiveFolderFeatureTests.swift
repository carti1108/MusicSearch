//
//  ArchiveFolderFeatureTests.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import Testing
import ComposableArchitecture
import ArchiveDomain
import ArchiveSharedTesting
import FeatureArchiveFolderTesting
@testable import FeatureArchiveFolder

@MainActor
struct ArchiveFolderFeatureTests {
    @Test func testOnAppear() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let yearString = formatter.string(from: Date())
        
        let tracks = [
            ArchivedTrack.stub(title: "A", artist: "B", genre: "Pop", rating: 5),
            ArchivedTrack.stub(title: "C", artist: "D", genre: "Pop", rating: 4)
        ]

        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: tracks)
        }

        await store.send(.onAppear)
        await store.receive(\.foldersLoaded) {
            $0.listenYearFolders = [
                FolderItem(title: "\(yearString)년 청취", subtitle: "2 곡", type: .listenYear(year: yearString))
            ]
            $0.genreFolders = [
                FolderItem(title: "Pop", subtitle: "2 곡", type: .genre(name: "Pop"))
            ]
            $0.ratingFolders = [
                FolderItem(title: "★★★★★", subtitle: "1 곡", type: .rating(value: 5)),
                FolderItem(title: "★★★★☆", subtitle: "1 곡", type: .rating(value: 4))
            ]
        }
    }

    @Test func testFolderTapped() async {
        let folder = FolderItem(title: "Pop", subtitle: "2 곡", type: .genre(name: "Pop"))

        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
        }

        await store.send(.folderTapped(folder))
        await store.receive(\.delegate.didTapFolder, folder)
    }
    
    @Test func testCloseButtonTapped() async {
        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
        }

        await store.send(.closeButtonTapped)
        await store.receive(\.delegate.didTapClose)
    }
}

final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    var tracks: [ArchivedTrack]
    init(tracks: [ArchivedTrack]) { self.tracks = tracks }

    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return tracks }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}
