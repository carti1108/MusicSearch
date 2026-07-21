import Foundation
import NetworkLayer

public final class MockNetworkManager: NetworkRequesting, @unchecked Sendable {
    public var errorToThrow: Error?
    public var responseToReturn: Any?
    
    public init(errorToThrow: Error? = nil, responseToReturn: Any? = nil) {
        self.errorToThrow = errorToThrow
        self.responseToReturn = responseToReturn
    }
    
    public func perform<T: Decodable, E: Requestable>(with endpoint: E, as type: T.Type) async throws -> T {
        if let error = errorToThrow {
            throw error
        }
        if let response = responseToReturn as? T {
            return response
        }
        fatalError("MockNetworkManager: Not implemented for this type")
    }
}
