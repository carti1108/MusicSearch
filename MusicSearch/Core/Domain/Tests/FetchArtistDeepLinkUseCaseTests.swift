import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct FetchArtistDeepLinkUseCaseTests {
    @Test("아티스트 이름을 전달했을 때 딥링크 URL을 정상적으로 반환하는가")
    func testExecute() async {
        // Given
        let mockService = MockMusicAppService()
        let expectedURL = URL(string: "music://artist/abc")
        mockService.fetchDeepLinkForArtistResult = expectedURL
        let useCase = FetchArtistDeepLinkUseCaseImpl(musicAppService: mockService)
        
        // When
        let url = await useCase.execute(artist: "ArtistName")
        
        // Then
        #expect(url == expectedURL)
    }
}
