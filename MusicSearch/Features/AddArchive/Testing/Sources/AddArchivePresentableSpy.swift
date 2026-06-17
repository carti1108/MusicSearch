import Foundation
import FeatureAddArchive
import ArchiveDomain

@MainActor
public final class AddArchivePresentableSpy: AddArchivePresentable {
	public var listener: AddArchivePresentableListener?
	
	public init() {}
	
	public var lastSavedTrack: ArchivedTrack?
	// If AddArchivePresentable had methods to update UI, we'd mock them here.
}

public final class AddArchiveListenerMock: AddArchiveListener {
	public init() {}
	
	public var didCloseAddArchiveCallCount = 0
	public func didCloseAddArchive() {
		didCloseAddArchiveCallCount += 1
	}
}
