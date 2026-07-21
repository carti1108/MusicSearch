import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct DisconnectMusicUseCaseTests {
    @Test("execute() 호출 시 AuthService의 disconnect가 정상적으로 호출되는가")
    func testExecute() {
        // Given
        let mockService = MockMusicAuthService()
        let useCase = DisconnectMusicUseCaseImpl(authService: mockService)
        
        #expect(mockService.disconnectCalled == false)
        
        // When
        useCase.execute()
        
        // Then
        #expect(mockService.disconnectCalled == true)
    }
}
