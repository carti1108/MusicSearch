//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import Combine
import MicroRIBs
import MSDomain
import ArchiveDomain
import TrackSearchDomain
import FeatureArchiveTrackSearch
import FeatureArchiveTrackSearchInterface

@MainActor
final class ExampleAppComponent: ArchiveTrackSearchDependency {
    let scenario: DemoScenario

    init(scenario: DemoScenario) {
        self.scenario = scenario
    }

    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }
    var searchTracksUseCase: SearchTracksUseCase {
        MockSearchTracksUseCase(scenario: scenario)
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockSearchTracksUseCase: SearchTracksUseCase {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario = .success) {
        self.scenario = scenario
    }
    
    func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
        switch scenario {
        case .success:
            return (tracks: [
                Track(title: "Searched Track 1", artist: "Artist 1", imageURL: nil),
                Track(title: "Searched Track 2", artist: "Artist 2", imageURL: nil)
            ], totalResults: 2)
        case .empty:
            return ([], 0)
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "검색 에러 발생"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return (tracks: [
                Track(title: "Delayed Track", artist: "Delayed Artist", imageURL: nil)
            ], totalResults: 1)
        }
    }
}
