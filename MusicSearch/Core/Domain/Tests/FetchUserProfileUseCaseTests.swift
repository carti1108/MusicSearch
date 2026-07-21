import Testing
import MSTesting
import Foundation
@testable import MSDomain

struct FetchUserProfileUseCaseTests {
    @Test("정상적으로 유저 프로필(이름과 이미지)을 가져오는가")
    func testExecuteSuccess() async throws {
        // Given
        let mockService = MockMusicAuthService()
        let expectedURL = URL(string: "https://example.com/image.png")
        mockService.fetchUserProfileResult = ("TestUser", expectedURL)
        let useCase = FetchUserProfileUseCaseImpl(authService: mockService)
        
        // When
        let result = try await useCase.execute()
        
        // Then
        #expect(result.name == "TestUser")
        #expect(result.imageURL == expectedURL)
    }

    @Test("유저 프로필을 가져오던 중 에러 발생 시 해당 에러를 다시 던지는가")
    func testExecuteFailure() async {
        // Given
        let mockService = MockMusicAuthService()
        struct TestError: Error {}
        mockService.fetchUserProfileError = TestError()
        let useCase = FetchUserProfileUseCaseImpl(authService: mockService)
        
        // When & Then
        await #expect(throws: TestError.self) {
            _ = try await useCase.execute()
        }
    }
}
