import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct ArrayTrackInfoTests {
    
    @Test("정상적인 트랙 배열 전달 시, 동시성 병렬 처리를 통해 모든 트랙에 이미지 URL이 채워져 반환되는가")
    func testEnrichingTrackInfoSuccess() async {
        // Given
        let originalTracks = [
            Track(id: "1", title: "T1", artist: "A1", imageURL: nil),
            Track(id: "2", title: "T2", artist: "A2", imageURL: nil),
            Track(id: "3", title: "T3", artist: "A3", imageURL: nil)
        ]
        
        // When
        let enriched = await originalTracks.enrichingTrackInfo(maxConcurrentRequests: 2) { track in
            return Track(
                id: track.id,
                title: track.title,
                artist: track.artist,
                imageURL: URL(string: "https://example.com/\(track.id).png")
            )
        }
        
        // Then
        #expect(enriched.count == 3)
        #expect(enriched[0].imageURL?.absoluteString == "https://example.com/1.png")
        #expect(enriched[1].imageURL?.absoluteString == "https://example.com/2.png")
        #expect(enriched[2].imageURL?.absoluteString == "https://example.com/3.png")
    }

    @Test("빈 배열을 전달했을 때 빈 배열을 그대로 반환하는가")
    func testEnrichingTrackInfoEmpty() async {
        // Given
        let emptyTracks: [Track] = []
        
        // When
        let enriched = await emptyTracks.enrichingTrackInfo { $0 }
        
        // Then
        #expect(enriched.isEmpty)
    }

    @Test("일부 트랙 보강 중 에러가 발생해도, 나머지 트랙들은 정상적으로 보강되어 전체 배열이 반환되는가")
    func testEnrichingTrackInfoPartialFailure() async {
        // Given
        let originalTracks = [
            Track(id: "1", title: "T1", artist: "A1", imageURL: nil),
            Track(id: "2", title: "T2", artist: "A2", imageURL: nil)
        ]
        
        struct TestError: Error {}
        
        // When
        let enriched = await originalTracks.enrichingTrackInfo(maxConcurrentRequests: 1) { track in
            if track.id == "1" {
                throw TestError()
            }
            return Track(
                id: track.id,
                title: track.title,
                artist: track.artist,
                imageURL: URL(string: "https://example.com/2.png")
            )
        }
        
        // Then
        #expect(enriched.count == 2)
        #expect(enriched[0].imageURL == nil)
        #expect(enriched[1].imageURL?.absoluteString == "https://example.com/2.png")
    }
}
