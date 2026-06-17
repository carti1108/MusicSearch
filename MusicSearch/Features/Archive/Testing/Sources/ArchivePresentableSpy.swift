import Foundation
import FeatureArchive
import ArchiveDomain

@MainActor
public final class ArchivePresentableSpy: ArchivePresentable {
	public var listener: ArchivePresentableListener?
	
	public init() {}

	public var updatedStateCallCount = 0
	public var lastUpdatedState: ArchiveState?
	public func update(state: ArchiveState) {
		updatedStateCallCount += 1
		lastUpdatedState = state
	}
}

public final class ArchiveListenerMock: ArchiveListener {
	public init() {}
	// Add listener methods if needed
}
