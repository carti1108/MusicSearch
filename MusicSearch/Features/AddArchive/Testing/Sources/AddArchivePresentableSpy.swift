import FeatureAddArchiveInterface
import FeatureAddArchive
import ArchiveDomain
import MSDomain

@MainActor
public final class AddArchivePresentableSpy: AddArchivePresentable {
	public var listener: AddArchivePresentableListener?
	
	public init() {}
	
	public var lastSavedTrack: ArchivedTrack?
	public var updateGenresCallCount = 0
	public var populateTrackCallCount = 0

	public func update(genres: [String]) {
		updateGenresCallCount += 1
	}

	public func populate(with track: Track) {
		populateTrackCallCount += 1
	}
}

@MainActor
public final class AddArchiveListenerMock: AddArchiveListener {
	public init() {}
	
	public var didCloseAddArchiveCallCount = 0
	public func didCloseAddArchive() {
		didCloseAddArchiveCallCount += 1
	}
}
