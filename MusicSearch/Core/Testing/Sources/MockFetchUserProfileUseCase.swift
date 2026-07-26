import Foundation
import MSDomain

public enum DemoScenario {
    case success
    case empty
    case error
    case delayed
}

public final class MockFetchUserProfileUseCase: FetchUserProfileUseCase, @unchecked Sendable {
    public var profile: (String, URL?)?
    public let scenario: DemoScenario
    
    public init(profile: (String, URL?)? = nil, scenario: DemoScenario = .success) {
        self.profile = profile
        self.scenario = scenario
    }
    
    public func execute() async throws -> (name: String, imageURL: URL?) {
        if let profile = profile { return profile }
        switch scenario {
        case .success:
            return (name: "Demo User", imageURL: nil)
        case .empty:
            return (name: "", imageURL: nil)
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "프로필 로드 에러"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return (name: "Delayed User", imageURL: nil)
        }
    }
}
