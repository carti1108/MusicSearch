import Foundation
import MSDomain

public final class MockGetMusicAccessTokenUseCase: GetMusicAccessTokenUseCase, @unchecked Sendable {
    public var token: String?
    public init(token: String? = "mock_token") {
        self.token = token
    }
    public func execute() -> String? {
        return self.token
    }
}
