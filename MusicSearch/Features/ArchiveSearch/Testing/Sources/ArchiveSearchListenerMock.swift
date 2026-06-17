import Foundation
import FeatureArchiveSearchInterface

public final class ArchiveSearchListenerMock: ArchiveSearchListener {
    public var didCloseArchiveSearchCallCount = 0
    
    public init() {}
    
    public func archiveSearchDidTapClose() {
        didCloseArchiveSearchCallCount += 1
    }
}
