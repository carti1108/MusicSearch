import Foundation
import FeatureArchiveFolderInterface

public final class ArchiveFolderListenerMock: ArchiveFolderListener {
    public var didCloseArchiveFolderCallCount = 0
    
    public init() {}
    
    public func archiveFolderDidTapClose() {
        didCloseArchiveFolderCallCount += 1
    }
}
