import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct AuthorizeMusicUseCaseTests {
    @Test("authorize() 호출 시 에러가 없으면 성공적으로 통과하는가")
    func testExecuteSuccess() async throws {
        // Given
        let mockService = MockMusicAuthService()
        let useCase = AuthorizeMusicUseCaseImpl(authService: mockService)
        
        // When & Then
        try await useCase.execute()
    }

    @Test("authorize() 호출 중 에러 발생 시 해당 에러를 다시 던지는가")
    func testExecuteFailure() async {
        // Given
        let mockService = MockMusicAuthService()
        struct TestError: Error {}
        mockService.authorizeError = TestError()
        let useCase = AuthorizeMusicUseCaseImpl(authService: mockService)
        
        // When & Then
        await #expect(throws: TestError.self) {
            try await useCase.execute()
        }
    }
}
