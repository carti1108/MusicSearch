import Foundation
import MicroRIBs
import FeatureArchive

@MainActor
public final class MockArchiveRouting: ArchiveRouting {
	public var interactable: Interactable {
		get { fatalError() }
		set { fatalError() }
	}
	public var children: [Routing] = []
	public var lifecycle: MicroRIBs.Observable<RouterLifecycle> {
		get { fatalError() }
	}

	public init() {}

	public func load() {}
	public func attachChild(_ child: Routing) {}
	public func detachChild(_ child: Routing) {}

	public var routeToAddArchiveCallCount = 0
	public func routeToAddArchive() {
		routeToAddArchiveCallCount += 1
	}

	public var detachAddArchiveCallCount = 0
	public func detachAddArchive() {
		detachAddArchiveCallCount += 1
	}
}
