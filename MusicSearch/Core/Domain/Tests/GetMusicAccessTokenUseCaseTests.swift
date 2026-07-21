import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct GetMusicAccessTokenUseCaseTests {
    @Test("액세스 토큰이 존재할 때 정상적으로 문자열을 반환하는가")
    func testExecuteSuccess() {
        // Given
        let mockService = MockMusicAuthService()
        mockService.getAccessTokenResult = "token123"
        let useCase = GetMusicAccessTokenUseCaseImpl(authService: mockService)
        
        // When
        let token = useCase.execute()
        
        // Then
        #expect(token == "token123")
    }

    @Test("액세스 토큰이 없을 때 nil을 반환하는가")
    func testExecuteNil() {
        // Given
        let mockService = MockMusicAuthService()
        mockService.getAccessTokenResult = nil
        let useCase = GetMusicAccessTokenUseCaseImpl(authService: mockService)
        
        // When
        let token = useCase.execute()
        
        // Then
        #expect(token == nil)
    }
}
