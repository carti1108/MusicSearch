//
//  ArrayArtistInfoTests.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Testing
import MSTesting
import Foundation
@testable import MSDomain

@Suite("Array+ArtistInfo Extension Tests")
struct ArrayArtistInfoTests {
    
    @Test("정상적으로 모든 아티스트의 이미지 URL을 보강하는가")
    func testEnrichSuccessfully() async throws {
        // Given
        let artists = [
            Artist(id: "1", name: "Muse", imageURL: nil, listeners: "1000", tags: [], bio: nil),
            Artist(id: "2", name: "Radiohead", imageURL: nil, listeners: "2000", tags: [], bio: nil)
        ]
        
        let fetchMock: @Sendable (String) async throws -> URL? = { name in
            if name == "Muse" {
                return URL(string: "https://muse.jpg")
            } else {
                return URL(string: "https://radiohead.jpg")
            }
        }
        
        // When
        let enrichedArtists = await artists.enrichingArtistImage(maxConcurrentRequests: 2, using: fetchMock)
        
        // Then
        #expect(enrichedArtists.count == 2)
        #expect(enrichedArtists[0].name == "Muse")
        #expect(enrichedArtists[0].imageURL == URL(string: "https://muse.jpg"))
        #expect(enrichedArtists[1].name == "Radiohead")
        #expect(enrichedArtists[1].imageURL == URL(string: "https://radiohead.jpg"))
    }
    
    @Test("병렬 통신 중 특정 아티스트의 요청이 실패하면, 실패한 객체만 원본 유지하고 나머지는 보강하는가")
    func testEnrichPartialFailureFallback() async throws {
        // Given
        let artists = [
            Artist(id: "1", name: "Muse", imageURL: nil, listeners: "1000", tags: [], bio: nil),
            Artist(id: "2", name: "Radiohead", imageURL: nil, listeners: "2000", tags: [], bio: nil),
            Artist(id: "3", name: "Coldplay", imageURL: nil, listeners: "3000", tags: [], bio: nil)
        ]
        
        struct MockError: Error {}
        
        let fetchMock: @Sendable (String) async throws -> URL? = { name in
            if name == "Radiohead" {
                throw MockError()
            }
            return URL(string: "https://\(name.lowercased()).jpg")
        }
        
        // When
        let enrichedArtists = await artists.enrichingArtistImage(maxConcurrentRequests: 2, using: fetchMock)
        
        // Then
        #expect(enrichedArtists.count == 3)
        #expect(enrichedArtists[0].imageURL == URL(string: "https://muse.jpg"))
        #expect(enrichedArtists[1].imageURL == nil)
        #expect(enrichedArtists[2].imageURL == URL(string: "https://coldplay.jpg"))
    }
}
