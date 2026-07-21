import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct FetchTrackDeepLinkUseCaseTests {
    @Test("Track 모델을 전달했을 때 딥링크 URL을 정상적으로 반환하는가")
    func testExecute() async {
        // Given
        let mockService = MockMusicAppService()
        let expectedURL = URL(string: "music://track/123")
        mockService.fetchDeepLinkForTrackResult = expectedURL
        let useCase = FetchTrackDeepLinkUseCaseImpl(musicAppService: mockService)
        
        let track = Track(title: "Title", artist: "Artist", imageURL: nil)
        
        // When
        let url = await useCase.execute(track: track)
        
        // Then
        #expect(url == expectedURL)
    }
}
