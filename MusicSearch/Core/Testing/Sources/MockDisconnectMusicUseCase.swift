import Foundation
import MSDomain

public final class MockDisconnectMusicUseCase: DisconnectMusicUseCase, @unchecked Sendable {
    public var disconnectCalled = false
    public init() {}
    public func execute() { self.disconnectCalled = true }
}
